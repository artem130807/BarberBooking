using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoSalons;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Salon.Queries.Handlers
{
    public class GetSalonsHandler : IRequestHandler<GetSalonsQuery, Result<List<DtoSalonShortInfo>>>
    {
        public GetSalonsHandler()
        {
            
        }
        public Task<Result<List<DtoSalonShortInfo>>> Handle(GetSalonsQuery query, CancellationToken cancellationToken)
        {
            throw new NotImplementedException();
        }
    }
}