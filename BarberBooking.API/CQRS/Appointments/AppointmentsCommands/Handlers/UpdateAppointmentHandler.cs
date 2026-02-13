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
    public class UpdateAppointmentHandler:IRequestHandler<UpdateAppointmentCommand, DtoClientAppointmentInfo>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IMapper _mapper;
        private readonly IUpdateAppointmentService _updateAppointmentService;
        public UpdateAppointmentHandler(IUnitOfWork unitOfWork, IAppointmentsRepository appointmentsRepository, IMapper mapper, IUpdateAppointmentService updateAppointmentService)
        {
            _unitOfWork = unitOfWork;
            _appointmentsRepository = appointmentsRepository;
            _mapper = mapper;
            _updateAppointmentService = updateAppointmentService;
        }

        public async Task<DtoClientAppointmentInfo> Handle(UpdateAppointmentCommand command, CancellationToken cancellationToken)
        {
            var appointment = await _appointmentsRepository.GetByIdAsync(command.Id);
            if(appointment == null)
                throw new InvalidOperationException("Такой записи не существует");
            try
            {
                _unitOfWork.BeginTransaction();
                await _updateAppointmentService.UpdateAsync(appointment, command.dtoUpdateAppointment);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                throw new InvalidOperationException(ex.Message);
            }
            return _mapper.Map<DtoClientAppointmentInfo>(appointment);
        }
    }
}