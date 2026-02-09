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
            var salons = await _salonsRepository.GetActiveSalons(userCity);
            var countSlotsInSalon = await _masterTimeSlotRepository.GetAvailableSlotsInSalons(DateOnly.FromDateTime(DateTime.Now));
            if(salons.Count == 0)
                return Result.Failure<List<DtoSalonShortInfo>>("Активные салоны в вашем городе не найдены");
            var dtoSalon = salons.Select(x =>
            {
                var dto =  _mapper.Map<DtoSalonShortInfo>(salons);
                dto.AvailableSlots = countSlotsInSalon.Count();
                return dto;
            }).ToList();
            return Result.Success(dtoSalon);
        }
    }
}