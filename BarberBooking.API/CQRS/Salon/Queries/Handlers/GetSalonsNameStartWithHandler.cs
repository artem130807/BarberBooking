using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoSalons;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Salon.Queries.Handlers
{
    public class GetSalonsNameStartWithHandler : IRequestHandler<GetSalonsNameStartWithQuery, Result<List<DtoSalonShortInfo>>>
    {
        public GetSalonsNameStartWithHandler()
        {
            
        }
        public Task<Result<List<DtoSalonShortInfo>>> Handle(GetSalonsNameStartWithQuery query, CancellationToken cancellationToken)
        {
            throw new NotImplementedException();
        }
    }
}