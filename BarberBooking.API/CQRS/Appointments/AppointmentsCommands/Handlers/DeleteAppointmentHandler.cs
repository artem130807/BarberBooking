using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoAppointments;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.AppointmentsCommands.Handlers
{
    public class DeleteAppointmentHandler : IRequestHandler<DeleteAppointmentCommand, Result<string>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IAppointmentsRepository _appointmentsRepository;
        public DeleteAppointmentHandler(IUnitOfWork unitOfWork, IAppointmentsRepository appointmentsRepository)
        {
            _unitOfWork = unitOfWork;
            _appointmentsRepository = appointmentsRepository;
        }
        public async Task<Result<string>> Handle(DeleteAppointmentCommand command, CancellationToken cancellationToken)
        {
            var appointment = await _appointmentsRepository.GetByIdAsync(command.Id);
            if(appointment == null)
                return Result.Failure<string>("Такой записи нету");
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.appointmentsRepository.DeleteAsync(command.Id);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                return Result.Failure<string>(ex.Message);
            }
            return "Успешно";
        }
    }
}