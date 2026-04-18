using System;
using System.Collections.Generic;
using BarberBooking.API.Dto.DtoRefreshTokens;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.RefreshTokens.Queries
{
    public record GetRefreshTokensByUserIdForAdminQuery(Guid UserId)
        : IRequest<Result<List<DtoRefreshTokenInfo>>>;
}
