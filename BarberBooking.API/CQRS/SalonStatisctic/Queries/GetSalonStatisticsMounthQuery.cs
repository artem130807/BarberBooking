using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoSalons;
using BarberBooking.API.Dto.DtoSalonStatistic;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.SalonStatisctic.Queries
{
    public record GetSalonStatisticsMounthQuery(Guid salonId, int mounth, DateOnly date):IRequest<Result<DtoSalonStatistic>>;
}