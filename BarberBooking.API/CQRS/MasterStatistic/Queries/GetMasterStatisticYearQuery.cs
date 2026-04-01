using System;
using BarberBooking.API.Dto.DtoMasterStatistic;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterStatistic.Queries
{
    public record GetMasterStatisticYearQuery(Guid masterProfileId, DateOnly date)
        : IRequest<Result<DtoMasterStatistic>>;
}
