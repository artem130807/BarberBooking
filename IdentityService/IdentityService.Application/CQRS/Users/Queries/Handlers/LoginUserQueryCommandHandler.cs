using CSharpFunctionalExtensions;
using IdentityService.Application.Contracts;
using IdentityService.Application.Dto;
using MediatR;

namespace IdentityService.Application.CQRS.Users.Queries.Handlers;

public class LoginUserQueryCommandHandler : IRequestHandler<LoginUserQuery, Result<AuthDto>>
{
    private readonly IUserRepository _usersRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtProvider _jwtProvider;
    private readonly IUserRolesRepository _userRolesRepository;
    private readonly IRefreshTokenRepository _refreshTokenRepository;
    private readonly IRefreshTokenService _refreshTokenService;

    public LoginUserQueryCommandHandler(
        IUserRepository usersRepository,
        IPasswordHasher passwordHasher,
        IJwtProvider jwtProvider,
        IUserRolesRepository userRolesRepository,
        IRefreshTokenRepository refreshTokenRepository,
        IRefreshTokenService refreshTokenService)
    {
        _usersRepository = usersRepository;
        _passwordHasher = passwordHasher;
        _jwtProvider = jwtProvider;
        _userRolesRepository = userRolesRepository;
        _refreshTokenRepository = refreshTokenRepository;
        _refreshTokenService = refreshTokenService;
    }

    public async Task<Result<AuthDto>> Handle(LoginUserQuery query, CancellationToken cancellationToken)
    {
        var user = await _usersRepository.GetUserByEmail(query.Email);
        if (user == null)
            return Result.Failure<AuthDto>("Пользователь не найден");

        if (!_passwordHasher.Verify(query.PasswordHash, user.PasswordHash))
            return Result.Failure<AuthDto>("Неверный пароль");

        var refreshToken = await _refreshTokenRepository.GetRefreshTokenByDevices(user.Id, query.devices);
        var token = await _jwtProvider.GenerateToken(user, query.devices);
        var roleInterface = await _userRolesRepository.GetMaxRole(user.Id);

        if (refreshToken == null)
        {
            var newToken = await _refreshTokenService.CreateToken(user.Id, query.devices);
            return Result.Success(new AuthDto
            {
                AccessToken = token,
                RefreshToken = newToken,
                Message = "Вход выполнен успешно",
                RoleInterface = roleInterface
            });
        }

        return Result.Success(new AuthDto
        {
            AccessToken = token,
            Message = "Вход выполнен успешно",
                RoleInterface = roleInterface
        });
    }
}
