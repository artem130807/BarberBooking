using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoAppointments;
using MediatR;

namespace BarberBooking.API.CQRS.AppointmentsCommands.Handlers
{
    public class DeleteAppointmentHandler : IRequestHandler<DeleteAppointmentCommand, DtoAppointmentInfo>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IMapper _mapper;
        public DeleteAppointmentHandler(IUnitOfWork unitOfWork, IAppointmentsRepository appointmentsRepository, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _appointmentsRepository = appointmentsRepository;
            _mapper = mapper;
        }
        public async Task<DtoAppointmentInfo> Handle(DeleteAppointmentCommand command, CancellationToken cancellationToken)
        {
            var appointment = await _appointmentsRepository.GetByIdAsync(command.Id);
            if(appointment == null)
                throw new InvalidOperationException("Такой записи нету");
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.appointmentsRepository.DeleteAsync(command.Id);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                throw new InvalidOperationException(ex.Message);
            }
            return _mapper.Map<DtoAppointmentInfo>(appointment);
        }
    }
}