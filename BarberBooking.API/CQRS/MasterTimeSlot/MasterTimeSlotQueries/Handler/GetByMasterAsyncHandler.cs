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
    public class GetByMasterAsyncHandler : IRequestHandler<GetByMasterAsyncQuery, Result<List<DtoMasterTimeSlotInfo>>>
    {
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        private readonly IMapper _mapper;
        public GetByMasterAsyncHandler(IMasterTimeSlotRepository masterTimeSlotRepository, IMapper mapper)
        {
            _masterTimeSlotRepository = masterTimeSlotRepository;
            _mapper = mapper;
        }
        public async Task<Result<List<DtoMasterTimeSlotInfo>>> Handle(GetByMasterAsyncQuery query, CancellationToken cancellationToken)
        {
            var timeslot = await _masterTimeSlotRepository.GetByMasterAsync(query.masterId, query.date);
            if(timeslot.Count == 0)
                return Result.Failure<List<DtoMasterTimeSlotInfo>>("Список тайм слотов пуст");
            var dto = _mapper.Map<List<DtoMasterTimeSlotInfo>>(timeslot);
            return Result.Success(dto);
        }
    }
}