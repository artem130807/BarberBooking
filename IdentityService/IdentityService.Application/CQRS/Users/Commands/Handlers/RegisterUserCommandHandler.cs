using CSharpFunctionalExtensions;
using IdentityService.Application.Contracts;
using IdentityService.Application.Dto;
using IdentityService.Domain.Enums;
using IdentityService.Domain.Models;
using IdentityService.Domain.ValueObjects;
using MediatR;

namespace IdentityService.Application.CQRS.Users.Commands.Handlers;

public class RegisterUserCommandHandler : IRequestHandler<RegisterUserCommand, Result<AuthDto>>
{
    private readonly IUserRepository _usersRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IJwtProvider _jwtProvider;
    private readonly IUserRolesRepository _userRolesRepository;
    private readonly IPasswordValidatorService _passwordValidatorService;
    private readonly IDnsEmailValidator _emailValidator;
    private readonly IUserValidatorService _userValidator;
    private readonly IRefreshTokenService _refreshTokenService;

    public RegisterUserCommandHandler(
        IUserRepository usersRepository,
        IPasswordHasher passwordHasher,
        IJwtProvider jwtProvider,
        IUserRolesRepository userRolesRepository,
        IPasswordValidatorService passwordValidatorService,
        IDnsEmailValidator emailValidator,
        IUserValidatorService userValidator,
        IRefreshTokenService refreshTokenService)
    {
        _usersRepository = usersRepository;
        _passwordHasher = passwordHasher;
        _jwtProvider = jwtProvider;
        _userRolesRepository = userRolesRepository;
        _passwordValidatorService = passwordValidatorService;
        _emailValidator = emailValidator;
        _userValidator = userValidator;
        _refreshTokenService = refreshTokenService;
    }

    public async Task<Result<AuthDto>> Handle(RegisterUserCommand command, CancellationToken cancellationToken)
    {
        var userValid = await _userValidator.ValidUser(command.dtoCreateUser);
        if (userValid.IsFailure)
            return Result.Failure<AuthDto>(userValid.Error);

        var passwordValid = await _passwordValidatorService.ValidatePasswordAsync(command.dtoCreateUser.PasswordHash);
        if (!passwordValid.IsValid)
            return Result.Failure<AuthDto>(passwordValid.Message);

        var emailValid = await _emailValidator.ValidateEmailAsync(command.dtoCreateUser.Email);
        if (emailValid.IsFailure)
            return Result.Failure<AuthDto>(emailValid.Error);

        var password = _passwordHasher.Generate(command.dtoCreateUser.PasswordHash);
        var role = await _userRolesRepository.GetUserRolesAsync((int)RolesEnum.User);
        if (role.Count == 0)
            return Result.Failure<AuthDto>("Р СњР ВµРЎвЂљРЎС“ РЎР‚Р С•Р В»Р С‘");

        var phoneResult = PhoneNumber.Create(command.dtoCreateUser.Phone.Number);
        if (phoneResult.IsFailure)
            return Result.Failure<AuthDto>(phoneResult.Error);

        var newUser = new IdentityService.Domain.Models.Users
        {
            Id = Guid.NewGuid(),
            Name = command.dtoCreateUser.Name,
            Phone = phoneResult.Value,
            Email = command.dtoCreateUser.Email,
            PasswordHash = password,
            City = command.dtoCreateUser.City,
            Roles = role
        };

        await _usersRepository.Register(newUser);

        var refreshToken = await _refreshTokenService.CreateToken(newUser.Id, command.dtoCreateUser.Devices);
        var token = await _jwtProvider.GenerateToken(newUser, command.dtoCreateUser.Devices);
        var roleInterface = await _userRolesRepository.GetMaxRole(newUser.Id);

        return Result.Success(new AuthDto
        {
            AccessToken = token,
            RefreshToken = refreshToken,
            Message = "Р вЂ™РЎвЂ№ РЎС“РЎРѓР С—Р ВµРЎв‚¬Р Р…Р С• Р В·Р В°РЎР‚Р ВµР С–Р С‘РЎРѓРЎвЂљРЎР‚Р С‘РЎР‚Р С•Р Р†Р В°Р В»Р С‘РЎРѓРЎРЉ",
            RoleInterface = roleInterface
        });
    }
}
