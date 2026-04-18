using System;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.RefreshTokens.Commands
{
    public record RevokedRefreshTokensForUserCommand(Guid UserId) : IRequest<Result<bool>>;
}
