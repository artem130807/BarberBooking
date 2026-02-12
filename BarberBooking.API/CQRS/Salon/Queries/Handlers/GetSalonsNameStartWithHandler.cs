using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Dto.DtoSalons;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Salon.Queries.Handlers
{
    public class GetSalonsNameStartWithHandler : IRequestHandler<GetSalonsNameStartWithQuery, Result<List<DtoSalonShortInfo>>>
    {
        private readonly ISalonsRepository _salonsRepository;
        private readonly IMapper _mapper;
        private readonly IUserContext _userContext;
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        public GetSalonsNameStartWithHandler(ISalonsRepository salonsRepository, IMapper mapper, IUserContext userContext, IMasterTimeSlotRepository masterTimeSlotRepository)
        {
            _salonsRepository = salonsRepository;
            _mapper = mapper;
            _userContext = userContext;
            _masterTimeSlotRepository = masterTimeSlotRepository;
        }
        public async Task<Result<List<DtoSalonShortInfo>>> Handle(GetSalonsNameStartWithQuery query, CancellationToken cancellationToken)
        {
            var userCity = _userContext.UserCity;
            var paramsFilter = new SearchFilterParams
            {
                SalonName = query.name,
                City = userCity,
            };
            var countSlotsInSalon = await _masterTimeSlotRepository.GetAvailableSlotsInSalons(DateOnly.FromDateTime(DateTime.Now));
            var salons = await _salonsRepository.GetSalonsNameStartWith(paramsFilter);
            if(salons.Count == 0)
                return Result.Failure<List<DtoSalonShortInfo>>("Салоны не найдены");
            var dtoSalon = salons.Select(salon =>
            {
                var dto =  _mapper.Map<DtoSalonShortInfo>(salon);
                dto.AvailableSlots = countSlotsInSalon.Count();
                return dto;
            }).ToList();
            return Result.Success(dtoSalon);
        }
    }
}