using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MessagesContracts;
using BarberBooking.API.Helpers;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Appointments.AppointmentsCommands.Handlers
{
    public class CompletedStatusAppointmentHandler : IRequestHandler<CompletedStatusAppointmentQuery, Result<string>>
    {
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly ISendMessageService _sendMessageService;
        private readonly IUserContext _userContext;
        public CompletedStatusAppointmentHandler(IAppointmentsRepository appointmentsRepository, IUnitOfWork unitOfWork, ISendMessageService sendMessageService, IUserContext userContext)
        {
            _appointmentsRepository = appointmentsRepository;
            _unitOfWork = unitOfWork;
            _sendMessageService = sendMessageService;
            _userContext = userContext;
        }
        public async Task<Result<string>> Handle(CompletedStatusAppointmentQuery query, CancellationToken cancellationToken)
        {
            var appointment = await _appointmentsRepository.GetByIdAsync(query.appointmentId);
            if(appointment == null)
                return Result.Failure<string>("Такой записи нету");
            var userId = _userContext.UserId;
            var isMaster = appointment.Master.UserId == userId;
            if (!isMaster)
                return Result.Failure<string>("Нет доступа");
            try
            {
                _unitOfWork.BeginTransaction();
                appointment.UpdateStatus(Enums.AppointmentStatusEnum.Completed);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                return Result.Failure<string>(ex.Message);
            }
         
            var userMessage = Models.Messages.Create($"Запись на {AppointmentMessageFormatting.FormatForMessage(appointment.AppointmentDate)}, завершена, не забудьте оставить отзыв", 
            appointment.ClientId.Value, appointment.Id,
            Enums.MessageAudience.User, Enums.TypeMessage.CompletedAppointment);
            var masterMessage = Models.Messages.Create($"Вы завершели запись, {appointment.Client.Name}, {appointment.Service.Name}, {AppointmentMessageFormatting.FormatForMessage(appointment.AppointmentDate)}",
                appointment.Master.UserId,
                appointment.Id, Enums.MessageAudience.Master,
                Enums.TypeMessage.CompletedAppointment);
                await _sendMessageService.Send(userMessage.Value);
                await _sendMessageService.Send(masterMessage.Value);
            
            return "Успешно";
        }
    }
}