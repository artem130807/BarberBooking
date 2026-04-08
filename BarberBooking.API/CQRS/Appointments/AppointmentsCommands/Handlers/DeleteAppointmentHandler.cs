using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MessagesContracts;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Helpers;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.AppointmentsCommands.Handlers
{
    public class DeleteAppointmentHandler : IRequestHandler<DeleteAppointmentCommand, Result<string>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly ISendMessageService _sendMessageService;
        private readonly IUserContext _userContext;
        public DeleteAppointmentHandler(
            IUnitOfWork unitOfWork,
            IAppointmentsRepository appointmentsRepository,
            ISendMessageService sendMessageService,
            IUserContext userContext)
        {
            _unitOfWork = unitOfWork;
            _appointmentsRepository = appointmentsRepository;
            _sendMessageService = sendMessageService;
            _userContext = userContext;
        }
        public async Task<Result<string>> Handle(DeleteAppointmentCommand command, CancellationToken cancellationToken)
        {
            var appointment = await _appointmentsRepository.GetByIdAsync(command.Id);
            if(appointment == null)
                return Result.Failure<string>("Такой записи нету");
            var userId = _userContext.UserId;
            var isClient = appointment.ClientId == userId;
            var isMaster = appointment.Master.UserId == userId;
            if (!isClient && !isMaster)
                return Result.Failure<string>("Нет доступа");
            try
            {
                _unitOfWork.BeginTransaction();
                appointment.UpdateStatus(Enums.AppointmentStatusEnum.Cancelled);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                return Result.Failure<string>(ex.Message);
            }
            if (isClient)
            {
                var userMessage = Models.Messages.Create($"Запись на {AppointmentMessageFormatting.FormatForMessage(appointment.AppointmentDate)}, отменена", appointment.ClientId, appointment.Id,
                    Enums.MessageAudience.User, Enums.TypeMessage.CancelledAppointment);
                var masterMessage = Models.Messages.Create($"Пользователь {appointment.Client.Name}, отменил запись к вам {appointment.Service.Name}, запись {AppointmentMessageFormatting.FormatForMessage(appointment.AppointmentDate)}",
                    appointment.Master.UserId,
                    appointment.Id, Enums.MessageAudience.Master,
                    Enums.TypeMessage.CancelledAppointment);
                await _sendMessageService.Send(userMessage.Value);
                await _sendMessageService.Send(masterMessage.Value);
            }
            else
            {
                var toClient = Models.Messages.Create(
                    $"Вы отменили запись на {AppointmentMessageFormatting.FormatForMessage(appointment.AppointmentDate)}, {appointment.Service.Name}",
                    appointment.ClientId,
                    appointment.Id,
                    Enums.MessageAudience.User,
                    Enums.TypeMessage.CancelledAppointment);
                await _sendMessageService.Send(toClient.Value);
            }
            return "Успешно";
        }
    }
}