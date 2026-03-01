using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoSalons;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Salon.Queries
{
    public record GetSalonsByServiceNameQuery(string serviceName, PageParams pageParams):IRequest<Result<PagedResult<DtoSalonShortInfo>>>;
}