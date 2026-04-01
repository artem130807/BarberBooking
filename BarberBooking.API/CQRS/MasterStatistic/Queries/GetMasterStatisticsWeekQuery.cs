using System;
using BarberBooking.API.Dto.DtoMasterStatistic;
using BarberBooking.API.Filters.Master;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterStatistic.Queries
{
    public record GetMasterStatisticsWeekQuery(Guid masterProfileId, MasterStatisticsParams statisticsParams)
        : IRequest<Result<DtoMasterStatistic>>;
}
