using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterTimeSlotQueries.Handler
{
    public class FindSlotAsyncHandler : IRequestHandler<FindSlotAsyncQuery, Result<DtoMasterTimeSlotInfo>>
    {
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        private readonly IMapper _mapper;
        public FindSlotAsyncHandler(IMasterTimeSlotRepository masterTimeSlotRepository, IMapper mapper)
        {
            _masterTimeSlotRepository = masterTimeSlotRepository;
            _mapper = mapper;
        }
        public async Task<Result<DtoMasterTimeSlotInfo>> Handle(FindSlotAsyncQuery query, CancellationToken cancellationToken)
        {
            var timeslot = await _masterTimeSlotRepository.FindSlotAsync(query.masterId, query.date, query.startTime);
            if(timeslot == null)
                return Result.Failure<DtoMasterTimeSlotInfo>("Тайм слот не найден");
            var result =  _mapper.Map<DtoMasterTimeSlotInfo>(timeslot);
            return Result.Success(result);
        }
    }
}