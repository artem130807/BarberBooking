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
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Salon.Queries.Handlers
{
    public class GetActiveSalonsHandler : IRequestHandler<GetActiveSalonsQuery, Result<List<DtoSalonShortInfo>>>
    {
        private readonly ISalonsRepository _salonsRepository;
        private readonly IMapper _mapper;
        private readonly IUserContext _userContext;
        private readonly IMasterTimeSlotRepository _masterTimeSlotRepository;
        private readonly ISalonPhotosRepository _salonPhotosRepository;
        public GetActiveSalonsHandler(ISalonsRepository salonsRepository, IMapper mapper, IUserContext userContext, IMasterTimeSlotRepository masterTimeSlotRepository, ISalonPhotosRepository salonPhotosRepository)
        {
            _salonsRepository = salonsRepository;
            _mapper = mapper;
            _userContext = userContext;
            _masterTimeSlotRepository = masterTimeSlotRepository;
            _salonPhotosRepository = salonPhotosRepository;
        }
        public async Task<Result<List<DtoSalonShortInfo>>> Handle(GetActiveSalonsQuery query, CancellationToken cancellationToken)
        {
            string userCity = _userContext.UserCity;
            var salons = await _salonsRepository.GetActiveSalons(userCity, query.pageParams);
            if(salons.Count == 0)
                return Result.Failure<List<DtoSalonShortInfo>>("Активные салоны в вашем городе не найдены");
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