using System;
using BarberBooking.API.Dto.DtoMasterStatistic;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterStatistic.Queries
{
    public record GetMasterStatisticsMounthQuery(Guid masterProfileId, int mounth, DateOnly date)
        : IRequest<Result<DtoMasterStatistic>>;
}
