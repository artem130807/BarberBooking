using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.CQRS.RefreshTokens.Commands;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.RefreshTokens.Commands.Handlers
{
    public class RevokedRefreshTokensForUserHandler
        : IRequestHandler<RevokedRefreshTokensForUserCommand, Result<bool>>
    {
        private readonly IRefreshTokenRepository _refreshTokenRepository;
        private readonly IUserContext _userContext;

        public RevokedRefreshTokensForUserHandler(
            IRefreshTokenRepository refreshTokenRepository,
            IUserContext userContext)
        {
            _refreshTokenRepository = refreshTokenRepository;
            _userContext = userContext;
        }

        public async Task<Result<bool>> Handle(
            RevokedRefreshTokensForUserCommand command,
            CancellationToken cancellationToken)
        {
            if (!_userContext.IsInRole("Admin"))
                return Result.Failure<bool>("Доступ запрещён");
            var refreshTokens = await _refreshTokenRepository.GetRefreshTokens(command.UserId);
            if (refreshTokens.Count == 0)
                return Result.Success(true);
            foreach (var refreshToken in refreshTokens)
            {
                refreshToken.RevokedToken();
            }
            await _refreshTokenRepository.SaveChangesAsync();
            return Result.Success(true);
        }
    }
}
