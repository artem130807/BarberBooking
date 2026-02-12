using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Domain.ValueObjects;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Models;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.AppointmentsCommands.Handlers
{
    public class CreateAppointmentHandler : IRequestHandler<CreateAppointmentCommand, Result<DtoCreateAppointmentInfo>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IMapper _mapper;
        private readonly IServicesRepository _servicesRepository;
        public CreateAppointmentHandler(IUnitOfWork unitOfWork, IAppointmentsRepository appointmentsRepository, IMapper mapper, IServicesRepository servicesRepository)
        {
            _unitOfWork = unitOfWork;
            _appointmentsRepository = appointmentsRepository;
            _mapper = mapper;
            _servicesRepository = servicesRepository;          
        }
        public async Task<Result<DtoCreateAppointmentInfo>> Handle(CreateAppointmentCommand command, CancellationToken cancellationToken)
        {
            var appointmentDate = await _appointmentsRepository.GetByMasterAndDateTimeAsync(command.DtoCreateAppointment.MasterId ,command.DtoCreateAppointment.AppointmentDate);
            if(appointmentDate != null)
                return Result.Failure<DtoCreateAppointmentInfo>("На это время уже есть запись");
            var service = await _servicesRepository.GetByIdAsync(command.DtoCreateAppointment.ServiceId);
            if(service == null)
                return Result.Failure<DtoCreateAppointmentInfo>("Услуги не существует");
            var dtoAppointmet = _mapper.Map<Appointments>(command.DtoCreateAppointment);
            var serviceDuration = TimeSpan.FromMinutes(service.DurationMinutes);
            var endTime = dtoAppointmet.StartTime.Add(serviceDuration);

            var appointment = Appointments.Create(dtoAppointmet.SalonId,dtoAppointmet.MasterId, dtoAppointmet.ClientId,
                dtoAppointmet.ServiceId, dtoAppointmet.TimeSlotId, dtoAppointmet.StartTime,
                dtoAppointmet.ClientNotes, endTime, dtoAppointmet.AppointmentDate);
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.appointmentsRepository.CreateAsync(appointment);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                throw new InvalidOperationException(ex.Message);
            }
          
            var result =  _mapper.Map<DtoCreateAppointmentInfo>(appointment);
            return Result.Success(result);
        }
    }
}