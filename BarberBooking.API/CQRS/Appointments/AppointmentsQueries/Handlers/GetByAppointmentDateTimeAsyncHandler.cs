using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoAppointments;
using MediatR;

namespace BarberBooking.API.CQRS.AppointmentsQueries.Handlers
{
    public class GetByAppointmentDateTimeAsyncHandler : IRequestHandler<GetByAppointmentDateTimeAsyncQuery, DtoAppointmentInfo>
    {
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IMapper _mapper;
        public GetByAppointmentDateTimeAsyncHandler(IAppointmentsRepository appointmentsRepository, IMapper mapper)
        {
            _appointmentsRepository = appointmentsRepository;
            _mapper = mapper;
        }
        public async Task<DtoAppointmentInfo> Handle(GetByAppointmentDateTimeAsyncQuery query, CancellationToken cancellationToken)
        {
            var appointment = await _appointmentsRepository.GetByMasterAndDateTimeAsync(query.masterId, query.appointmentDateTime);
            return _mapper.Map<DtoAppointmentInfo>(appointment);
        }
    }
}