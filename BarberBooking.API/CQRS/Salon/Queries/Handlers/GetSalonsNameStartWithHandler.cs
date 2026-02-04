using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Dto.DtoSalons;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Salon.Queries.Handlers
{
    public class GetSalonsNameStartWithHandler : IRequestHandler<GetSalonsNameStartWithQuery, Result<List<DtoSalonShortInfo>>>
    {
        private readonly ISalonsRepository _salonsRepository;
        private readonly IMapper _mapper;
        public GetSalonsNameStartWithHandler(ISalonsRepository salonsRepository, IMapper mapper)
        {
            _salonsRepository = salonsRepository;
            _mapper = mapper;
        }
        public async Task<Result<List<DtoSalonShortInfo>>> Handle(GetSalonsNameStartWithQuery query, CancellationToken cancellationToken)
        {
            var salons = await _salonsRepository.GetSalonsNameStartWith(query.searchFilterParams);
            if(salons.Count == 0)
                return Result.Failure<List<DtoSalonShortInfo>>("Салоны не найдены");
            var dtoSalon =  _mapper.Map<List<DtoSalonShortInfo>>(salons);
            return Result.Success(dtoSalon);
        }
    }
}