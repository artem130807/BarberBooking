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
    public class GetByMasterTodayAsyncHandler : IRequestHandler<GetByMasterTodayAsyncQuery, List<DtoAppointmentInfo>>
    {
        private readonly IAppointmentsRepository _appointmentsRepository;
        private readonly IMapper _mapper;
        public GetByMasterTodayAsyncHandler(IAppointmentsRepository appointmentsRepository, IMapper mapper)
        {
            _appointmentsRepository = appointmentsRepository;
            _mapper = mapper;
        }
        public async Task<List<DtoAppointmentInfo>> Handle(GetByMasterTodayAsyncQuery query, CancellationToken cancellationToken)
        {
            var appointment = await _appointmentsRepository.GetByMasterTodayAsync(query.masterId);
            return _mapper.Map<List<DtoAppointmentInfo>>(appointment);
        }

      
    }
}