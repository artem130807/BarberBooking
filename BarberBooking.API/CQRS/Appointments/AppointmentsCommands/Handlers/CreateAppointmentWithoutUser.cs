using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.AppointmentContracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.MasterTimeSlotContracts;
using BarberBooking.API.Contracts.MessagesContracts;
using BarberBooking.API.Helpers;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Appointments.AppointmentsCommands.Handlers
{
    public class CreateAppointmentWithoutUserHandler : IRequestHandler<CreateAppointmentWithoutUserQuery, Result<string>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IUserContext _userContext;
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly ISendMessageService _sendMessageService;
        private readonly IAppointmentWithOutUserCreationValidator _appointmentCreationValidator;
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        private readonly ITimeSlotQualifierBookedService _timeSlotQualifierBookedService;
        private readonly IMasterProfileRepository _masterProfileRepository;
        public CreateAppointmentWithoutUserHandler(IUnitOfWork unitOfWork,  IUserContext userContext, ISendMessageService sendMessageService, IAppointmentWithOutUserCreationValidator appointmentCreationValidator,  IAppointmentsRepository appointmentsRepository,
            IMasterTimeSlotRepository masterTimeSlotRepository,
            ITimeSlotQualifierBookedService timeSlotQualifierBookedService, IMasterProfileRepository masterProfileRepository)
        {
              _unitOfWork = unitOfWork;
            _userContext = userContext;
            _sendMessageService = sendMessageService;
            _appointmentCreationValidator = appointmentCreationValidator;
            _appointmentsRepository = appointmentsRepository;
            _masterTimeSlotRepository = masterTimeSlotRepository;
            _timeSlotQualifierBookedService = timeSlotQualifierBookedService;
            _masterProfileRepository = masterProfileRepository;
        }   
        public async Task<Result<string>> Handle(CreateAppointmentWithoutUserQuery command, CancellationToken cancellationToken)
        {
           var userId = _userContext.UserId;
           var masterProfile = await _masterProfileRepository.GetMasterProfileByUserId(userId);
           if(masterProfile == null)
            return Result.Failure<string>("Профиль мастера не найден");

            var validation = await _appointmentCreationValidator.ValidateAsync(
                command.dtoCreateAppointment, userId, cancellationToken);
            if (validation.IsFailure)
                return Result.Failure<string>(validation.Error);

            var draft = validation.Value;
            var appointment = Models.Appointments.Create(
                draft.MappedAppointment.SalonId,
                masterProfile.Id,
                draft.MappedAppointment.ServiceId,
                draft.MappedAppointment.TimeSlotId,
                draft.MappedAppointment.StartTime,
                draft.MappedAppointment.ClientNotes,
                draft.EndTime,
                draft.MappedAppointment.AppointmentDate);
            try
            {
                _unitOfWork.BeginTransaction();
                await _masterTimeSlotRepository.ForUpdate(appointment.TimeSlotId);
                var conflicting = await _appointmentsRepository.GetOverlappingConfirmedAppointment(
                    appointment.TimeSlotId,
                    appointment.AppointmentDate,
                    appointment.StartTime,
                    appointment.EndTime);
                if (conflicting != null)
                {
                    _unitOfWork.RollBack();
                    return Result.Failure<string>("Слот занят");
                }
                await _unitOfWork.appointmentsRepository.CreateAsync(appointment);
                _unitOfWork.Commit();
            }
            catch (Exception ex)
            {
                _unitOfWork.RollBack();
                var detailedMessage = ex.InnerException?.Message ?? ex.Message;
                throw new InvalidOperationException($"Ошибка сохранения записи: {detailedMessage}", ex);
            }
            var scheduleDate = DateOnly.FromDateTime(appointment.AppointmentDate);
            await _timeSlotQualifierBookedService.Handle(appointment.TimeSlotId, scheduleDate);

            var serviceEntity = await _unitOfWork.servicesRepository.GetByIdAsync(appointment.ServiceId);
            var serviceName = string.IsNullOrWhiteSpace(serviceEntity?.Name) ? "услуга" : serviceEntity!.Name.Trim();

            var masterMessage = Models.Messages.Create(
            $"Вы записали пользователя на {serviceName}, запись {AppointmentMessageFormatting.FormatForMessage(appointment.AppointmentDate)}",
            masterProfile.UserId,
            appointment.Id,
            Enums.MessageAudience.Master,
            Enums.TypeMessage.CreationAppointment);
            if (masterMessage.IsFailure)
                return Result.Failure<string>(masterMessage.Error);
            await _sendMessageService.Send(masterMessage.Value);
            return Result.Success("Успешно");
        }
    }
}