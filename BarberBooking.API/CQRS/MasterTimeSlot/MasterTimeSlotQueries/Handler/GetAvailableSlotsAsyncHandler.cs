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
    public class GetAvailableSlotsAsyncHandler : IRequestHandler<GetAvailableSlotsAsyncQuery, Result<List<DtoMasterTimeSlotInfo>>>
    {
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        private readonly IMapper _mapper;
        public GetAvailableSlotsAsyncHandler(IMasterTimeSlotRepository masterTimeSlotRepository, IMapper mapper)
        {
            _masterTimeSlotRepository = masterTimeSlotRepository;
            _mapper = mapper;
        }
        public async Task<Result<List<DtoMasterTimeSlotInfo>>> Handle(GetAvailableSlotsAsyncQuery query, CancellationToken cancellationToken)
        {
            var timeslots = await _masterTimeSlotRepository.GetAvailableSlotsAsync(query.masterId, query.date, query.serviceDuration);
            if(timeslots.Count == 0)
                return Result.Failure<List<DtoMasterTimeSlotInfo>>("Список слотов пуст");
            var dto = _mapper.Map<List<DtoMasterTimeSlotInfo>>(timeslots);
            return Result.Success(dto);
        }
    }
}