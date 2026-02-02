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
    public class GetActiveSalonsHandler : IRequestHandler<GetActiveSalonsQuery, Result<List<DtoSalonShortInfo>>>
    {
        private readonly ISalonsRepository _salonsRepository;
        private readonly IMapper _mapper;
        public GetActiveSalonsHandler(ISalonsRepository salonsRepository, IMapper mapper)
        {
            _salonsRepository = salonsRepository;
            _mapper = mapper;
        }
        public Task<Result<List<DtoSalonShortInfo>>> Handle(GetActiveSalonsQuery query, CancellationToken cancellationToken)
        {
            throw new NotImplementedException();
        }
    }
}