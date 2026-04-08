using System;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.MasterTimeSlotContracts;
using BarberBooking.API.Contracts.MessagesContracts;
using BarberBooking.API.Helpers;
using BarberBooking.API.Models;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.AppointmentsCommands.Handlers
{
    public class CreateAppointmentHandler : IRequestHandler<CreateAppointmentCommand, Result<string>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IUserContext _userContext;
        private readonly ISendMessageService _sendMessageService;
        private readonly IAppointmentCreationValidator _appointmentCreationValidator;
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        private readonly ITimeSlotQualifierBookedService _timeSlotQualifierBookedService;
        public CreateAppointmentHandler(
            IUnitOfWork unitOfWork,
            IUserContext userContext,
            ISendMessageService sendMessageService,
            IAppointmentCreationValidator appointmentCreationValidator,
            IAppointmentsRepository appointmentsRepository,
            IMasterTimeSlotRepository masterTimeSlotRepository,
            ITimeSlotQualifierBookedService timeSlotQualifierBookedService
            )
        {
            _unitOfWork = unitOfWork;
            _userContext = userContext;
            _sendMessageService = sendMessageService;
            _appointmentCreationValidator = appointmentCreationValidator;
            _appointmentsRepository = appointmentsRepository;
            _masterTimeSlotRepository = masterTimeSlotRepository;
            _timeSlotQualifierBookedService = timeSlotQualifierBookedService;
        }

        public async Task<Result<string>> Handle(CreateAppointmentCommand command, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var validation = await _appointmentCreationValidator.ValidateAsync(
                command.DtoCreateAppointment, userId, cancellationToken);
            if (validation.IsFailure)
                return Result.Failure<string>(validation.Error);

            var draft = validation.Value;
            var appointment = Models.Appointments.Create(
                draft.MappedAppointment.SalonId,
                draft.MappedAppointment.MasterId,
                userId,
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

            var clientUser = await _unitOfWork.userRepository.GetUserById(userId);
            var serviceEntity = await _unitOfWork.servicesRepository.GetByIdAsync(appointment.ServiceId);
            var masterProfile = await _unitOfWork.masterProfileRepository.GetMasterProfileById(appointment.MasterId);

            var clientName = string.IsNullOrWhiteSpace(clientUser?.Name) ? "Клиент" : clientUser!.Name.Trim();
            var serviceName = string.IsNullOrWhiteSpace(serviceEntity?.Name) ? "услуга" : serviceEntity!.Name.Trim();

            var userMessage = Models.Messages.Create(
                $"Запись на {AppointmentMessageFormatting.FormatForMessage(appointment.AppointmentDate)}, успешно создана",
                userId,
                appointment.Id,
                Enums.MessageAudience.User,
                Enums.TypeMessage.CreationAppointment);
            if (userMessage.IsFailure)
                return Result.Failure<string>(userMessage.Error);
            await _sendMessageService.Send(userMessage.Value);

            if (masterProfile != null && masterProfile.UserId != Guid.Empty)
            {
                var masterMessage = Models.Messages.Create(
                    $"Пользователь {clientName}, записался к вам на {serviceName}, запись {AppointmentMessageFormatting.FormatForMessage(appointment.AppointmentDate)}",
                    masterProfile.UserId,
                    appointment.Id,
                    Enums.MessageAudience.Master,
                    Enums.TypeMessage.CreationAppointment);
                if (masterMessage.IsFailure)
                    return Result.Failure<string>(masterMessage.Error);
                await _sendMessageService.Send(masterMessage.Value);
            }

            return Result.Success("Успешно");
        }
    }
}
