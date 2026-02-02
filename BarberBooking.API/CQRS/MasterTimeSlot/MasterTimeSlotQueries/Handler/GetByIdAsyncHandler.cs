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
    public class GetByIdAsyncHandler : IRequestHandler<GetByIdAsyncQuery, DtoMasterTimeSlotInfo>
    {
        
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        private readonly IMapper _mapper;
        public GetByIdAsyncHandler(IMasterTimeSlotRepository masterTimeSlotRepository, IMapper mapper)
        {
            _masterTimeSlotRepository = masterTimeSlotRepository;
            _mapper = mapper;
        }

        public async Task<DtoMasterTimeSlotInfo> Handle(GetByIdAsyncQuery query, CancellationToken cancellationToken)
        {
            var timeslot = await _masterTimeSlotRepository.GetByIdAsync(query.Id);
            return _mapper.Map<DtoMasterTimeSlotInfo>(timeslot);
        }
    }
}