using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Dto.DtoSalons;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Salon.Queries.Handlers
{
    public class GetSalonsByFilterHandler : IRequestHandler<GetSalonsByFilterQuery, Result<List<DtoSalonShortInfo>>>
    {
        private readonly ISalonsRepository _salonsRepository;
        private readonly IUserContext _userContext;
        private readonly IMapper _mapper;
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        public GetSalonsByFilterHandler(ISalonsRepository salonsRepository, IUserContext userContext, IMapper mapper, IMasterTimeSlotRepository masterTimeSlotRepository)
        {
            _salonsRepository = salonsRepository;
            _userContext = userContext;
            _mapper = mapper;
            _masterTimeSlotRepository = masterTimeSlotRepository;
        }
        public async Task<Result<List<DtoSalonShortInfo>>> Handle(GetSalonsByFilterQuery query, CancellationToken cancellationToken)
        {
            var userCity = _userContext.UserCity;
            var salons = await _salonsRepository.GetSalonsByFilter(userCity, query.salonFilter, query.pageParams);
            if(salons == null)
                return Result.Failure<List<DtoSalonShortInfo>>("Списков салонов пуст");
            var date = DateOnly.FromDateTime(DateTime.Now);
            var dtoList = salons.Data.Select(s => _mapper.Map<DtoSalonShortInfo>(s)).ToList();
            var slotCounts = await _masterTimeSlotRepository.GetAvailableSlotsCountBySalonIdsAsync(
                dtoList.Select(d => d.Id).ToList(),
                date,
                cancellationToken);
            foreach (var dto in dtoList)
            {
                dto.AvailableSlots = slotCounts.TryGetValue(dto.Id, out var c) ? c : 0;
            }

            return Result.Success(dtoList);
        }
    }
}