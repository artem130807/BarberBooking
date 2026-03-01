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
    public class GetSalonsByServiceNameHandler : IRequestHandler<GetSalonsByServiceNameQuery ,Result<PagedResult<DtoSalonShortInfo>>>
    {
        private readonly ISalonsRepository _salonsRepository;
        private readonly IUserContext _userContext;
        private readonly IMapper _mapper;
        public GetSalonsByServiceNameHandler(ISalonsRepository salonsRepository, IUserContext userContext, IMapper mapper)
        {
            _salonsRepository = salonsRepository;
            _userContext = userContext;
            _mapper = mapper;
        }

        public async Task<Result<PagedResult<DtoSalonShortInfo>>> Handle(GetSalonsByServiceNameQuery query, CancellationToken cancellationToken)
        {
            var userCity = _userContext.UserCity;
            if(userCity == null)
                return Result.Failure<PagedResult<DtoSalonShortInfo>>("Ваш город неопределён");
            var salons = await _salonsRepository.GetSalonsByServiceName(query.serviceName, userCity, query.pageParams);
            if(salons.Count == 0)
                return Result.Failure<PagedResult<DtoSalonShortInfo>>("Салоны с такой услугой не найдены");
            
            var result = _mapper.Map<PagedResult<DtoSalonShortInfo>>(salons);
            return Result.Success(result);
        }
    }
}