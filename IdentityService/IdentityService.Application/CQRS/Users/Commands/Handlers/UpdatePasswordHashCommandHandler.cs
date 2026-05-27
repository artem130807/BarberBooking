using CSharpFunctionalExtensions;
using IdentityService.Application.Contracts;
using IdentityService.Application.Contracts.Events;
using IdentityService.Application.Contracts.Interfaces;
using IdentityService.Application.Dto.Users;
using MediatR;

namespace IdentityService.Application.CQRS.Users.Commands.Handlers;

public class UpdatePasswordHashCommandHandler : IRequestHandler<UpdatePasswordHashCommand, Result<DtoUpdatePasswordResult>>
{
    private readonly IUserRepository _usersRepository;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IPasswordValidatorService _passwordValidator;
    private readonly IRabbitMqService _rabbitMqService;
    private readonly IUnitOfWork _unitOfWork;
    private readonly IVerifyEmailGrpcAdapter _verifyEmailGrpcAdapter;
    public UpdatePasswordHashCommandHandler(
        IUserRepository usersRepository,
        IPasswordHasher passwordHasher,
        IPasswordValidatorService passwordValidator,
        IRabbitMqService rabbitMqService, 
        IUnitOfWork unitOfWork,
        IVerifyEmailGrpcAdapter verifyEmailGrpcAdapter)
    {
        _usersRepository = usersRepository;
        _passwordHasher = passwordHasher;
        _passwordValidator = passwordValidator;
        _rabbitMqService = rabbitMqService;
        _unitOfWork = unitOfWork;
        _verifyEmailGrpcAdapter = verifyEmailGrpcAdapter;
    }

    public async Task<Result<DtoUpdatePasswordResult>> Handle(UpdatePasswordHashCommand command,
        CancellationToken cancellationToken)
    {
        var user = await _usersRepository.GetUserByEmail(command.dtoUpdatePassword.Email);
        if (user == null)
            return Result.Failure<DtoUpdatePasswordResult>("Пользователя с таким адресом почты не существует");

        var passwordValid = await _passwordValidator.ValidatePasswordAsync(command.dtoUpdatePassword.PasswordHash);
        if (!passwordValid.IsValid)
            return Result.Failure<DtoUpdatePasswordResult>(passwordValid.Message);
        var IsVerifyEmail = await _verifyEmailGrpcAdapter.IsVerifyEmail(command.dtoUpdatePassword.Email, cancellationToken);
        if(IsVerifyEmail == false)
        {
            return Result.Failure<DtoUpdatePasswordResult>("Вы не подтвердили email");
        }
        var passwordHash = _passwordHasher.Generate(command.dtoUpdatePassword.PasswordHash);
        try
        {
            _unitOfWork.BeginTransaction();
            await _usersRepository.UpdatePasswordHash(command.dtoUpdatePassword.Email, passwordHash);
            _unitOfWork.Commit();
        }catch(Exception ex)
        {
            _unitOfWork.RollBack();
            return Result.Failure<DtoUpdatePasswordResult>($"Ошибка смены пароля: {ex.Message}");
        }
        
        return Result.Success(new DtoUpdatePasswordResult { Message = "РЈСЃРїРµС€РЅРѕ", IsSuccess = true });
    }
}
