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
    public record GetSalonsByFilterQuery(SalonFilter salonFilter, PageParams pageParams):IRequest<Result<List<DtoSalonShortInfo>>>;
}