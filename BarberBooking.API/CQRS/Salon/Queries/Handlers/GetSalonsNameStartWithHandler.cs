using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.SalonPhotosContracts;
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
        private readonly ILogger<GetSalonsNameStartWithHandler> _logger;
        private readonly ISalonPhotosRepository _salonPhotosRepository;
        public GetSalonsNameStartWithHandler(ISalonsRepository salonsRepository, IMapper mapper, IUserContext userContext, IMasterTimeSlotRepository masterTimeSlotRepository, ILogger<GetSalonsNameStartWithHandler> logger, ISalonPhotosRepository salonPhotosRepository)
        {
            _salonsRepository = salonsRepository;
            _mapper = mapper;
            _userContext = userContext;
            _masterTimeSlotRepository = masterTimeSlotRepository;
            _logger = logger;
            _salonPhotosRepository = salonPhotosRepository;
        }
        public async Task<Result<List<DtoSalonShortInfo>>> Handle(GetSalonsNameStartWithQuery query, CancellationToken cancellationToken)
        {
        
            var userCity = _userContext.UserCity;
            var paramsFilter = new SearchFilterParams
            {
                SalonName = query.name,
                City = userCity
            };
            _logger.LogInformation($"Фильтры {paramsFilter}");
            var salons = await _salonsRepository.GetSalonsNameStartWith(paramsFilter, query.pageParams);
            if(salons.Count == 0)
                return Result.Failure<List<DtoSalonShortInfo>>("Салоны не найдены");
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
            foreach (var s in dtoList)
            {
                s.MainPhotoUrl = await _salonPhotosRepository.GetFirstPhotoUrlAsync(s.Id, cancellationToken) ?? string.Empty;
            }
            return Result.Success(dtoList);
        }
    }
}