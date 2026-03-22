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
            var availableSlots = await _masterTimeSlotRepository.GetAvailableSlotsInSalons(DateOnly.FromDateTime(DateTime.Now));
            var slotsBySalonId = availableSlots
                .Where(x => x.Master != null)
                .GroupBy(x => x.Master.SalonId)
                .ToDictionary(g => g.Key, g => g.Count());
            if(salons == null)
                return Result.Failure<List<DtoSalonShortInfo>>("Списков салонов пуст");
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