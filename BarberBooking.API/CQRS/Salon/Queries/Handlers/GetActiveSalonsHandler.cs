using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Dto.DtoSalons;
using CSharpFunctionalExtensions;
using MediatR;
using Microsoft.AspNetCore.DataProtection.KeyManagement.Internal;

namespace BarberBooking.API.CQRS.Salon.Queries.Handlers
{
    public class GetActiveSalonsHandler : IRequestHandler<GetActiveSalonsQuery, Result<List<DtoSalonShortInfo>>>
    {
        private readonly ISalonsRepository _salonsRepository;
        private readonly IMapper _mapper;
        private readonly IUserContext _userContext;
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        public GetActiveSalonsHandler(ISalonsRepository salonsRepository, IMapper mapper, IUserContext userContext, IMasterTimeSlotRepository masterTimeSlotRepository)
        {
            _salonsRepository = salonsRepository;
            _mapper = mapper;
            _userContext = userContext;
            _masterTimeSlotRepository = masterTimeSlotRepository;
        }
        public async Task<Result<List<DtoSalonShortInfo>>> Handle(GetActiveSalonsQuery query, CancellationToken cancellationToken)
        {
            string userCity = _userContext.UserCity;
            var salons = await _salonsRepository.GetActiveSalons(userCity, query.pageParams);
            var availableSlots = await _masterTimeSlotRepository.GetAvailableSlotsInSalons(DateOnly.FromDateTime(DateTime.Now));
            var slotsBySalonId = availableSlots
                .Where(x => x.Master != null)
                .GroupBy(x => x.Master.SalonId)
                .ToDictionary(g => g.Key, g => g.Count());
            if(salons.Count == 0)
                return Result.Failure<List<DtoSalonShortInfo>>("Активные салоны в вашем городе не найдены");
            var dtoSalon = salons.Data.Select(salon =>
            {
                var dto =  _mapper.Map<DtoSalonShortInfo>(salon);
                dto.AvailableSlots = slotsBySalonId.TryGetValue(salon.Id, out var count) ? count : 0;
                return dto;
            }).ToList();
            return Result.Success(dtoSalon);
        }
    }
}