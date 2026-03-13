using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoServices;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.Services;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Services.ServicesQueries
{
    public record GetServicesNameStartWithQuery(string name, PageParams pageParams):IRequest<Result<PagedResult<DtoServicesSearchResult>>>;
}