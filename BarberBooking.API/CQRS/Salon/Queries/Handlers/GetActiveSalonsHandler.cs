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
        private readonly ICacheService _cacheService;
        private readonly IUserContext _userContext;
        public GetActiveSalonsHandler(ISalonsRepository salonsRepository, IMapper mapper, ICacheService cacheService,IUserContext userContext)
        {
            _salonsRepository = salonsRepository;
            _mapper = mapper;
            _cacheService = cacheService;
            _userContext = userContext;
        }
        public async Task<Result<List<DtoSalonShortInfo>>> Handle(GetActiveSalonsQuery query, CancellationToken cancellationToken)
        {
            string userCity = _userContext.UserCity;
            var salons = await _salonsRepository.GetActiveSalons(userCity);
            if(salons.Count == 0)
                return Result.Failure<List<DtoSalonShortInfo>>("Активные салоны в вашем городе не найдены");
            var dtoSalon =  _mapper.Map<List<DtoSalonShortInfo>>(salons);
            return Result.Success(dtoSalon);
        }
    }
}