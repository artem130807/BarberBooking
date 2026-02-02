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
    public class GetByIdAsyncHandler : IRequestHandler<GetByIdAsyncQuery, DtoAppointmentInfo>
    {
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IMapper _mapper;
        public GetByIdAsyncHandler(IAppointmentsRepository appointmentsRepository, IMapper mapper)
        {
            _appointmentsRepository = appointmentsRepository;
            _mapper = mapper;
        }
        public async Task<DtoAppointmentInfo> Handle(GetByIdAsyncQuery query, CancellationToken cancellationToken)
        {
            var appointment = await _appointmentsRepository.GetByIdAsync(query.Id);
            return _mapper.Map<DtoAppointmentInfo>(appointment);
        }
    }
}