using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterTimeSlotQueries.Handler
{
    public class GetByIdAsyncHandler : IRequestHandler<GetByIdAsyncQuery, Result<DtoMasterTimeSlotInfo>>
    {
        
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        private readonly IMapper _mapper;
        public GetByIdAsyncHandler(IMasterTimeSlotRepository masterTimeSlotRepository, IMapper mapper)
        {
            _masterTimeSlotRepository = masterTimeSlotRepository;
            _mapper = mapper;
        }

        public async Task<Result<DtoMasterTimeSlotInfo>> Handle(GetByIdAsyncQuery query, CancellationToken cancellationToken)
        {
            var timeslot = await _masterTimeSlotRepository.GetByIdAsync(query.Id);
            if(timeslot == null)
                Result.Failure<DtoMasterTimeSlotInfo>("Тайм слот не найден");
            var dto = _mapper.Map<DtoMasterTimeSlotInfo>(timeslot);
            return Result.Success(dto);
        }
    }
}