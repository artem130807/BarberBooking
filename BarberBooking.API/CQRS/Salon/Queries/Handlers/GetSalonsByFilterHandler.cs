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
        public GetSalonsByFilterHandler(ISalonsRepository salonsRepository, IUserContext userContext, IMapper mapper)
        {
            _salonsRepository = salonsRepository;
            _userContext = userContext;
            _mapper = mapper;
        }
        public async Task<Result<List<DtoSalonShortInfo>>> Handle(GetSalonsByFilterQuery query, CancellationToken cancellationToken)
        {
            var userCity = _userContext.UserCity;
            var salons = await _salonsRepository.GetSalonsByFilter(userCity, query.salonFilter);
            if(salons == null)
                return Result.Failure<List<DtoSalonShortInfo>>("Списков салонов пуст");
            return _mapper.Map<List<DtoSalonShortInfo>>(salons);
        }
    }
}