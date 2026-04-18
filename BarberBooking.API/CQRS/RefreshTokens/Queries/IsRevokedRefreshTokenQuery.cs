using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MediatR;

namespace BarberBooking.API.CQRS.RefreshTokens.Queries
{
    public record IsRevokedRefreshTokenQuery(string TokenBase64) : IRequest<bool>;
}