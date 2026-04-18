using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using MediatR;

namespace BarberBooking.API.CQRS.RefreshTokens.Queries.Handlers
{
    public class IsRevokedRefreshTokenHandler : IRequestHandler<IsRevokedRefreshTokenQuery, bool>
    {
        private readonly IRefreshTokenRepository _refreshTokenRepository;
        public IsRevokedRefreshTokenHandler(IRefreshTokenRepository refreshTokenRepository)
        {
            _refreshTokenRepository = refreshTokenRepository;  
        }
        public async Task<bool> Handle(IsRevokedRefreshTokenQuery query, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(query.TokenBase64))
                return true;
            var refreshToken = await _refreshTokenRepository.GetRefreshTokenByToken(query.TokenBase64.Trim());
            if (refreshToken == null)
                return true;
            return refreshToken.IsRevoked;
        }
    }
}