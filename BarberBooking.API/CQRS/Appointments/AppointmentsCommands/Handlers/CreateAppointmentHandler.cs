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
using Microsoft.AspNetCore.SignalR;

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
                var timeSlot = await _masterTimeSlotRepository.ForUpdate(appointment.TimeSlotId);
                var activeAppointment = await _appointmentsRepository.GetAppointmentActive(appointment.TimeSlotId);
                if (activeAppointment != null)
                    return Result.Failure<string>("Слот занят");
                await _unitOfWork.appointmentsRepository.CreateAsync(appointment);
                _unitOfWork.Commit();
            }
            catch (Exception ex)
            {
                _unitOfWork.RollBack();
                var detailedMessage = ex.InnerException?.Message ?? ex.Message;
                throw new InvalidOperationException($"Ошибка сохранения записи: {detailedMessage}", ex);
            }
            await _timeSlotQualifierBookedService.Handle(appointment.TimeSlotId, appointment.TimeSlot.ScheduleDate);
            var userMessage = Models.Messages.Create($"Запись на {AppointmentMessageFormatting.FormatForMessage(appointment.AppointmentDate)}, успешно создана", userId, appointment.Id, 
            Enums.MessageAudience.User, Enums.TypeMessage.CreationAppointment);
            var masterMessage = Models.Messages.Create($"Пользователь {appointment.Client.Name}, записался к вам на {appointment.Service.Name}, запись {AppointmentMessageFormatting.FormatForMessage(appointment.AppointmentDate)}",
            appointment.Master.UserId, 
            appointment.Id, Enums.MessageAudience.Master, 
            Enums.TypeMessage.CreationAppointment);
            await _sendMessageService.Send(userMessage.Value);
            await _sendMessageService.Send(masterMessage.Value);
            return Result.Success("Успешно");
        }
    }
}
