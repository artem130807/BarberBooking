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
    public class GetAppointmentsAsyncHandler : IRequestHandler<GetAppointmentsAsyncQuery, List<DtoAppointmentInfo>>
    {
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IMapper _mapper;
        public GetAppointmentsAsyncHandler(IAppointmentsRepository appointmentsRepository, IMapper mapper)
        {
            _appointmentsRepository = appointmentsRepository;
            _mapper = mapper;
        }
        public async Task<List<DtoAppointmentInfo>> Handle(GetAppointmentsAsyncQuery query, CancellationToken cancellationToken)
        {
            var appointment = await _appointmentsRepository.GetAppointmentsAsync();
            return _mapper.Map<List<DtoAppointmentInfo>>(appointment);
        }
    }
}