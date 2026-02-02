using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using MediatR;

namespace BarberBooking.API.CQRS.MasterTimeSlotQueries.Handler
{
    public class GetAvailableSlotsAsyncHandler : IRequestHandler<GetAvailableSlotsAsyncQuery, List<DtoMasterTimeSlotInfo>>
    {
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        private readonly IMapper _mapper;
        public GetAvailableSlotsAsyncHandler(IMasterTimeSlotRepository masterTimeSlotRepository, IMapper mapper)
        {
            _masterTimeSlotRepository = masterTimeSlotRepository;
            _mapper = mapper;
        }
        public async Task<List<DtoMasterTimeSlotInfo>> Handle(GetAvailableSlotsAsyncQuery query, CancellationToken cancellationToken)
        {
            var timeslots = await _masterTimeSlotRepository.GetAvailableSlotsAsync(query.masterId, query.date, query.serviceDuration);
            return _mapper.Map<List<DtoMasterTimeSlotInfo>>(timeslots);
        }
    }
}