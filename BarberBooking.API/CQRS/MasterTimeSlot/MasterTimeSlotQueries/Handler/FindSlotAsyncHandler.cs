using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using MediatR;

namespace BarberBooking.API.CQRS.MasterTimeSlotQueries.Handler
{
    public class FindSlotAsyncHandler : IRequestHandler<FindSlotAsyncQuery, DtoMasterTimeSlotInfo>
    {
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        private readonly IMapper _mapper;
        public FindSlotAsyncHandler(IMasterTimeSlotRepository masterTimeSlotRepository, IMapper mapper)
        {
            _masterTimeSlotRepository = masterTimeSlotRepository;
            _mapper = mapper;
        }
        public async Task<DtoMasterTimeSlotInfo> Handle(FindSlotAsyncQuery query, CancellationToken cancellationToken)
        {
            var timeslot = await _masterTimeSlotRepository.FindSlotAsync(query.masterId, query.date, query.startTime);
            return _mapper.Map<DtoMasterTimeSlotInfo>(timeslot);
        }
    }
}