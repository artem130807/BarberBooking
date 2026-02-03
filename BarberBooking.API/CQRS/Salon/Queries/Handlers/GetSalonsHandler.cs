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
    public class GetSalonsHandler : IRequestHandler<GetSalonsQuery, Result<List<DtoSalonShortInfo>>>
    {
        private readonly ISalonsRepository _salonsRepository;
        private readonly IMapper _mapper;
        public GetSalonsHandler(ISalonsRepository salonsRepository, IMapper mapper)
        {
            _salonsRepository = salonsRepository;
            _mapper = mapper;
        }
        public async Task<Result<List<DtoSalonShortInfo>>> Handle(GetSalonsQuery query, CancellationToken cancellationToken)
        {
            var salons = await _salonsRepository.GetSalons(query.city);
            if(salons.Count == 0)
                return Result.Failure<List<DtoSalonShortInfo>>("Салоны в вашем городе не найдены");
            var dtoSalon =  _mapper.Map<List<DtoSalonShortInfo>>(salons);
            return Result.Success(dtoSalon);
        }
    }
}