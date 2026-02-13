using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoAppointments;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Appointments.AppointmentsQueries.Handlers
{
    public class GetAppointmentMasterByIdHandler : IRequestHandler<GetAppointmentMasterByIdQuery, Result<DtoMasterAppointmentInfo>>
    {
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IMapper _mapper;
        public GetAppointmentMasterByIdHandler(IAppointmentsRepository appointmentsRepository, IMapper mapper)
        {
            _appointmentsRepository = appointmentsRepository;
            _mapper = mapper;
        }

        public async Task<Result<DtoMasterAppointmentInfo>> Handle(GetAppointmentMasterByIdQuery query, CancellationToken cancellationToken)
        {
            var appointment = await _appointmentsRepository.GetByIdAsync(query.Id);
            if(appointment == null)
                return Result.Failure<DtoMasterAppointmentInfo>("Запись не найдена");
            var result = _mapper.Map<DtoMasterAppointmentInfo>(appointment);
            return Result.Success(result);
        }
    }
}