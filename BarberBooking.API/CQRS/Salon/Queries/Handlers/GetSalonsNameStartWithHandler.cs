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
        public GetSalonsNameStartWithHandler(ISalonsRepository salonsRepository, IMapper mapper, IUserContext userContext)
        {
            _salonsRepository = salonsRepository;
            _mapper = mapper;
            _userContext = userContext;
        }
        public async Task<Result<List<DtoSalonShortInfo>>> Handle(GetSalonsNameStartWithQuery query, CancellationToken cancellationToken)
        {
            var userCity = _userContext.UserCity;
            var paramsFilter = new SearchFilterParams
            {
                SalonName = query.name,
                City = userCity,
            };
            var salons = await _salonsRepository.GetSalonsNameStartWith(paramsFilter);
            if(salons.Count == 0)
                return Result.Failure<List<DtoSalonShortInfo>>("Салоны не найдены");
            var dtoSalon =  _mapper.Map<List<DtoSalonShortInfo>>(salons);
            return Result.Success(dtoSalon);
        }
    }
}