using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MessagesContracts;
using BarberBooking.API.Dto.DtoAppointments;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.AppointmentsCommands.Handlers
{
    public class DeleteAppointmentHandler : IRequestHandler<DeleteAppointmentCommand, Result<string>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly ISendMessageService _sendMessageService;
        public DeleteAppointmentHandler(IUnitOfWork unitOfWork, IAppointmentsRepository appointmentsRepository, ISendMessageService sendMessageService)
        {
            _unitOfWork = unitOfWork;
            _appointmentsRepository = appointmentsRepository;
            _sendMessageService = sendMessageService;
        }
        public async Task<Result<string>> Handle(DeleteAppointmentCommand command, CancellationToken cancellationToken)
        {
            var appointment = await _appointmentsRepository.GetByIdAsync(command.Id);
            if(appointment == null)
                return Result.Failure<string>("Такой записи нету");
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
            var userMessage = Models.Messages.Create($"Запись на {appointment.AppointmentDate}, отменена", appointment.ClientId, appointment.Id, 
            Enums.MessageAudience.User, Enums.TypeMessage.CancelledAppointment);
            var masterMessage = Models.Messages.Create($"Пользователь {appointment.Client.Name}, отменил запись к вам {appointment.Service.Name}, запись {appointment.AppointmentDate}",
            appointment.Master.UserId, 
            appointment.Id, Enums.MessageAudience.Master, 
            Enums.TypeMessage.CancelledAppointment);
            await _sendMessageService.Send(userMessage.Value);
            await _sendMessageService.Send(masterMessage.Value);
            return "Успешно";
        }
    }
}