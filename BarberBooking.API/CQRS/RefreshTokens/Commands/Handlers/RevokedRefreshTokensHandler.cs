using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.RefreshTokens.Commands.Handlers
{
    public class RevokedRefreshTokensHandler : IRequestHandler<RevokedRefreshTokensCommand, Result<bool>>
    {
        private readonly IRefreshTokenRepository _refreshTokenRepository;
        private readonly IUserContext _userContext;
        public RevokedRefreshTokensHandler(IRefreshTokenRepository refreshTokenRepository,  IUserContext userContext)
        {
            _refreshTokenRepository = refreshTokenRepository;
            _userContext = userContext;
        }
        public async Task<Result<bool>> Handle(RevokedRefreshTokensCommand command, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var refreshTokens = await _refreshTokenRepository.GetRefreshTokens(userId);
            if(refreshTokens.Count == 0)
                return Result.Success(true);
            foreach(var refreshToken in refreshTokens)
            {
                refreshToken.RevokedToken();
            }
            await _refreshTokenRepository.SaveChangesAsync();
            return Result.Success(true);
        }
    }
}