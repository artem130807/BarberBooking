using CSharpFunctionalExtensions;
using IdentityService.Application.Contracts;
using IdentityService.Application.Dto.Users;

namespace IdentityService.Infrastructure.Validators;

public class UserValidatorService : IUserValidatorService
{
    private readonly IUserRepository _userRepository;
    private readonly ICityService _cityService;

    public UserValidatorService(IUserRepository userRepository, ICityService cityService)
    {
        _userRepository = userRepository;
        _cityService = cityService;
    }

    public async Task<Result> ValidUser(DtoCreateUser dtoCreateUser)
    {
        var userByEmail = await _userRepository.GetUserByEmail(dtoCreateUser.Email);
        if (userByEmail != null)
            return Result.Failure("Пользователь с таким адресом почты уже зарегистрирован");

        var userByPhone = await _userRepository.GetUserByPhone(dtoCreateUser.Phone.Number);
        if (userByPhone != null)
            return Result.Failure("Пользователь с таким номером телефона уже зарегистрирован");

        if (!_cityService.IsCityValid(dtoCreateUser.City))
            return Result.Failure("Вы указали неверный город");

        if (string.IsNullOrWhiteSpace(dtoCreateUser.Name))
            return Result.Failure("Укажите имя");

        if (string.IsNullOrWhiteSpace(dtoCreateUser.Phone.Number))
            return Result.Failure("Укажите номер телефона");

        if (string.IsNullOrWhiteSpace(dtoCreateUser.Email))
            return Result.Failure("Укажите адрес электронной почты");

        if (string.IsNullOrWhiteSpace(dtoCreateUser.PasswordHash))
            return Result.Failure("Укажите пароль");

        if (string.IsNullOrWhiteSpace(dtoCreateUser.City))
            return Result.Failure("Укажите город");

        return Result.Success();
    }
}
