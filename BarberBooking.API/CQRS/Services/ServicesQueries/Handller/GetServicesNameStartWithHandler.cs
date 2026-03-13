using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using Azure.Core;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoServices;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.Services;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Services.ServicesQueries.Handller
{
    public class GetServicesNameStartWithHandler : IRequestHandler<GetServicesNameStartWithQuery, Result<PagedResult<DtoServicesSearchResult>>>
    {
        private readonly IMapper _mapper;
        private readonly IServicesRepository _servicesRepository;
        private readonly IUserContext _userContext;
        public GetServicesNameStartWithHandler(IMapper mapper, IServicesRepository servicesRepository, IUserContext userContext)
        {
            _mapper = mapper;
            _servicesRepository = servicesRepository;
            _userContext = userContext;
        }
        public async Task<Result<PagedResult<DtoServicesSearchResult>>> Handle(GetServicesNameStartWithQuery query, CancellationToken cancellationToken)
        {
            var userCity = _userContext.UserCity;
            var searchParams = new SearchServicesParams
            {
                ServiceName = query.name,
                City = userCity
            };
            var services = await _servicesRepository.GetServicesNameStartWith(searchParams, query.pageParams);
            if(services.Count == 0)
                return Result.Failure<PagedResult<DtoServicesSearchResult>>("Список услуг в вашем городе пуст");
            var result = _mapper.Map<PagedResult<DtoServicesSearchResult>>(services);
            return Result.Success(result);
        }
    }
}