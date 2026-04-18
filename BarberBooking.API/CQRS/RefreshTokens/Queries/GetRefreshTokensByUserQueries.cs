using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoRefreshTokens;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.RefreshTokens.Queries
{
    public record GetRefreshTokensByUserQueries():IRequest<Result<List<DtoRefreshTokenInfo>>>;
}