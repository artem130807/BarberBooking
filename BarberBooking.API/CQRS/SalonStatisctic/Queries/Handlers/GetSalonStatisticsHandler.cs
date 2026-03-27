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

namespace BarberBooking.API.CQRS.SalonStatisctic.Queries
{
    public class GetSalonStatisticsHandler : IRequestHandler<GetSalonStatisticsQuery, Result<List<SalonStatsDto>>>
    {
        private readonly ISalonStatisticRepository _salonStatisticRepository;
        private readonly IUserContext _userContext;
        private readonly IMapper _mapper;
        public GetSalonStatisticsHandler(ISalonStatisticRepository salonStatisticRepository, IUserContext userContext, IMapper mapper)
        {
            _salonStatisticRepository = salonStatisticRepository;
            _userContext = userContext;
            _mapper = mapper;
        }
        public async Task<Result<List<SalonStatsDto>>> Handle(GetSalonStatisticsQuery query, CancellationToken cancellationToken)
        {
            var userCity = _userContext.UserCity;
            var state = await _salonStatisticRepository.GetSalonStatisticsByFilter(query.salonStatisticsFilter, userCity);
            if(state.Count == 0)
                return Result.Failure<List<SalonStatsDto>>("Нету записей");
            var result = _mapper.Map<List<SalonStatsDto>>(state);
            return Result.Success(result);
        }
    }
}