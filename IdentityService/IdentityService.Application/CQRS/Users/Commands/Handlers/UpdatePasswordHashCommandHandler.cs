using CSharpFunctionalExtensions;
using IdentityService.Application.Contracts;
using IdentityService.Application.Dto.Users;
using MediatR;

namespace IdentityService.Application.CQRS.Users.Commands.Handlers;

public class UpdatePasswordHashCommandHandler : IRequestHandler<UpdatePasswordHashCommand, Result<DtoUpdatePasswordResult>>
{
    private readonly IUserRepository _usersRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IPasswordValidatorService _passwordValidator;

    public UpdatePasswordHashCommandHandler(
        IUserRepository usersRepository,
        IPasswordHasher passwordHasher,
        IPasswordValidatorService passwordValidator)
    {
        _usersRepository = usersRepository;
        _passwordHasher = passwordHasher;
        _passwordValidator = passwordValidator;
    }

    public async Task<Result<DtoUpdatePasswordResult>> Handle(UpdatePasswordHashCommand command,
        CancellationToken cancellationToken)
    {
        var user = await _usersRepository.GetUserByEmail(command.dtoUpdatePassword.Email);
        if (user == null)
            return Result.Failure<DtoUpdatePasswordResult>("РџРѕР»СЊР·РѕРІР°С‚РµР»СЏ СЃ С‚Р°РєРёРј email РЅРµ СЃСѓС‰РµСЃС‚РІСѓРµС‚");

        var passwordValid = await _passwordValidator.ValidatePasswordAsync(command.dtoUpdatePassword.PasswordHash);
        if (!passwordValid.IsValid)
            return Result.Failure<DtoUpdatePasswordResult>(passwordValid.Message);

        var passwordHash = _passwordHasher.Generate(command.dtoUpdatePassword.PasswordHash);
        await _usersRepository.UpdatePasswordHash(command.dtoUpdatePassword.Email, passwordHash);
        return Result.Success(new DtoUpdatePasswordResult { Message = "РЈСЃРїРµС€РЅРѕ", IsSuccess = true });
    }
}
