using System;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.CQRS.RefreshTokens.Commands;
using BarberBooking.API.Dto;
using BarberBooking.API.Provider;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.RefreshTokens.Commands.Handlers
{
    public class RefreshAccessTokenHandler : IRequestHandler<RefreshAccessTokenCommand, Result<AuthDto>>
    {
        private readonly IRefreshTokenRepository _refreshTokenRepository;
        private readonly IUserRepository _userRepository;
        private readonly IJwtProvider _jwtProvider;
        private readonly IUserRolesRepository _userRolesRepository;

        public RefreshAccessTokenHandler(
            IRefreshTokenRepository refreshTokenRepository,
            IUserRepository userRepository,
            IJwtProvider jwtProvider,
            IUserRolesRepository userRolesRepository)
        {
            _refreshTokenRepository = refreshTokenRepository;
            _userRepository = userRepository;
            _jwtProvider = jwtProvider;
            _userRolesRepository = userRolesRepository;
        }

        public async Task<Result<AuthDto>> Handle(RefreshAccessTokenCommand command, CancellationToken cancellationToken)
        {
            if (string.IsNullOrWhiteSpace(command.RefreshTokenBase64) || string.IsNullOrWhiteSpace(command.Devices))
                return Result.Failure<AuthDto>("Недопустимый запрос");

            var refreshToken = await _refreshTokenRepository.GetRefreshTokenByToken(command.RefreshTokenBase64.Trim());
            if (refreshToken == null)
                return Result.Failure<AuthDto>("Сессия недействительна");
            if (refreshToken.IsRevoked)
                return Result.Failure<AuthDto>("Сессия отозвана");
            if (refreshToken.ExpiresAt < DateTime.UtcNow)
                return Result.Failure<AuthDto>("Сессия истекла");
            if (!string.Equals(refreshToken.Devices, command.Devices, StringComparison.Ordinal))
                return Result.Failure<AuthDto>("Несоответствие устройства");

            var user = await _userRepository.GetUserById(refreshToken.UserId);
            if (user == null)
                return Result.Failure<AuthDto>("Пользователь не найден");

            var accessToken = await _jwtProvider.GenerateToken(user, command.Devices);
            var roleInterface = await _userRolesRepository.GetMaxRole(user.Id);
            return Result.Success(new AuthDto
            {
                AccessToken = accessToken,
                Message = "Токен обновлён",
                RoleInterface = roleInterface
            });
        }
    }
}
