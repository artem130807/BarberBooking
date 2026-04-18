using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.RefreshTokens.Commands
{
    public record RevokedRefreshTokenCommand(Guid Id):IRequest<Result<bool>>;
}