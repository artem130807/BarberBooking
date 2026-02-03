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
    public class GetSalonByIdHandler : IRequestHandler<GetSalonByIdQuery, Result<DtoSalonInfo>>
    {
        private readonly ISalonsRepository _salonsRepository;
        private readonly IMapper _mapper;
        public GetSalonByIdHandler(ISalonsRepository salonsRepository, IMapper mapper)
        {
            _salonsRepository = salonsRepository;
            _mapper = mapper;
        }
        public async Task<Result<DtoSalonInfo>> Handle(GetSalonByIdQuery query, CancellationToken cancellationToken)
        {
            var salon = await _salonsRepository.GetSalonById(query.Id);
            if(salon == null)
                return Result.Failure<DtoSalonInfo>("Салон не найден");
            var result = _mapper.Map<DtoSalonInfo>(salon);
            return Result.Success(result);
        }
    }
}