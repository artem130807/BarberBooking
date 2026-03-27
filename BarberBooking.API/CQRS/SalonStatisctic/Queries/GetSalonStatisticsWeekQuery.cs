using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoSalonStatistic;
using BarberBooking.API.Filters.Salon;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.SalonStatisctic.Queries
{
    public record GetSalonStatisticsWeekQuery(Guid salonId, SalonStatisticsParams statisticsParams):IRequest<Result<DtoSalonStatistic>>;
}