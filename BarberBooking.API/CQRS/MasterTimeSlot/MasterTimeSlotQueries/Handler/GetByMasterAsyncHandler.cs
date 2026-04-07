using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterTimeSlotQueries.Handler
{
    public class GetByMasterAsyncHandler : IRequestHandler<GetByMasterAsyncQuery, Result<List<DtoMasterTimeSlotInfo>>>
    {
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        private readonly IMapper _mapper;
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;

        public GetByMasterAsyncHandler(
            IMasterTimeSlotRepository masterTimeSlotRepository,
            IMapper mapper,
            IUserContext userContext,
            IMasterProfileRepository masterProfileRepository)
        {
            _masterTimeSlotRepository = masterTimeSlotRepository;
            _mapper = mapper;
            _userContext = userContext;
            _masterProfileRepository = masterProfileRepository;
        }

        public async Task<Result<List<DtoMasterTimeSlotInfo>>> Handle(GetByMasterAsyncQuery query, CancellationToken cancellationToken)
        {
            var master = await _masterProfileRepository.GetMasterProfileByUserId(_userContext.UserId);
            if (master == null)
                return Result.Failure<List<DtoMasterTimeSlotInfo>>("Доступно только мастеру");
            if (master.Id != query.masterId)
                return Result.Failure<List<DtoMasterTimeSlotInfo>>("Нет доступа");

            var timeslot = await _masterTimeSlotRepository.GetByMasterAsync(query.masterId, query.date);
            if (timeslot.Count == 0)
                return Result.Success(new List<DtoMasterTimeSlotInfo>());
            var dto = _mapper.Map<List<DtoMasterTimeSlotInfo>>(timeslot);
            return Result.Success(dto);
        }
    }
}
