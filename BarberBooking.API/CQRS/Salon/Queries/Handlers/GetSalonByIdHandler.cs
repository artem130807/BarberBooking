using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoSalons;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Salon.Queries.Handlers
{
    public class GetSalonByIdHandler : IRequestHandler<GetSalonByIdQuery, Result<DtoSalonInfo>>
    {
        public GetSalonByIdHandler()
        {
            
        }
        public Task<Result<DtoSalonInfo>> Handle(GetSalonByIdQuery query, CancellationToken cancellationToken)
        {
            throw new NotImplementedException();
        }
    }
}