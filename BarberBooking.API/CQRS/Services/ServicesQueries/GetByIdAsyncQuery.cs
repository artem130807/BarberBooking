using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoServices;
using MediatR;

namespace BarberBooking.API.CQRS.ServicesQueries
{
    public record GetByIdAsyncQuery(Guid id):IRequest<DtoServicesInfo>;
}