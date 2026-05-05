using CSharpFunctionalExtensions;
using IdentityService.Application.Contracts;
using IdentityService.Application.Dto;
using MediatR;

namespace IdentityService.Application.CQRS.RefreshTokens.Commands.Handlers;

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
            return Result.Failure<AuthDto>("РќРµРґРѕРїСѓСЃС‚РёРјС‹Рµ РґР°РЅРЅС‹Рµ");

        var refreshToken = await _refreshTokenRepository.GetRefreshTokenByToken(command.RefreshTokenBase64.Trim());
        if (refreshToken == null)
            return Result.Failure<AuthDto>("РўРѕРєРµРЅ РЅРµРґРµР№СЃС‚РІРёС‚РµР»СЊРЅС‹Р№");
        if (refreshToken.IsRevoked)
            return Result.Failure<AuthDto>("РўРѕРєРµРЅ РѕС‚РѕР·РІР°РЅ");
        if (refreshToken.ExpiresAt < DateTime.UtcNow)
            return Result.Failure<AuthDto>("РўРѕРєРµРЅ РёСЃС‚С‘Рє");
        if (!string.Equals(refreshToken.Devices, command.Devices, StringComparison.Ordinal))
            return Result.Failure<AuthDto>("РќРµСЃРѕРѕС‚РІРµС‚СЃС‚РІРёРµ СѓСЃС‚СЂРѕР№СЃС‚РІР°");

        var user = await _userRepository.GetUserById(refreshToken.UserId);
        if (user == null)
            return Result.Failure<AuthDto>("РџРѕР»СЊР·РѕРІР°С‚РµР»СЊ РЅРµ РЅР°Р№РґРµРЅ");

        var accessToken = await _jwtProvider.GenerateToken(user, command.Devices);
        var roleInterface = await _userRolesRepository.GetMaxRole(user.Id);

        return Result.Success(new AuthDto
        {
            AccessToken = accessToken,
            Message = "РўРѕРєРµРЅ РѕР±РЅРѕРІР»С‘РЅ",
            RoleInterface = roleInterface
        });
    }
}
