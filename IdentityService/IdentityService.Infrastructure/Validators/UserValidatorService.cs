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
            return Result.Failure("РџРѕР»СЊР·РѕРІР°С‚РµР»СЊ СЃ С‚Р°РєРёРј email СѓР¶Рµ СЃСѓС‰РµСЃС‚РІСѓРµС‚");

        var userByPhone = await _userRepository.GetUserByPhone(dtoCreateUser.Phone.Number);
        if (userByPhone != null)
            return Result.Failure("РџРѕР»СЊР·РѕРІР°С‚РµР»СЊ СЃ С‚Р°РєРёРј РЅРѕРјРµСЂРѕРј С‚РµР»РµС„РѕРЅР° СѓР¶Рµ СЃСѓС‰РµСЃС‚РІСѓРµС‚");

        if (!_cityService.IsCityValid(dtoCreateUser.City))
            return Result.Failure("Р’С‹ СѓРєР°Р·Р°Р»Рё РЅРµРІРµСЂРЅС‹Р№ РіРѕСЂРѕРґ");

        if (string.IsNullOrWhiteSpace(dtoCreateUser.Name))
            return Result.Failure("Р’С‹ РЅРµ СѓРєР°Р·Р°Р»Рё РёРјСЏ");

        if (string.IsNullOrWhiteSpace(dtoCreateUser.Phone.Number))
            return Result.Failure("Р’С‹ РЅРµ СѓРєР°Р·Р°Р»Рё РЅРѕРјРµСЂ");

        if (string.IsNullOrWhiteSpace(dtoCreateUser.Email))
            return Result.Failure("Р’С‹ РЅРµ СѓРєР°Р·Р°Р»Рё РїРѕС‡С‚Сѓ");

        if (string.IsNullOrWhiteSpace(dtoCreateUser.PasswordHash))
            return Result.Failure("Р’С‹ РЅРµ СѓРєР°Р·Р°Р»Рё РїР°СЂРѕР»СЊ");

        if (string.IsNullOrWhiteSpace(dtoCreateUser.City))
            return Result.Failure("Р’С‹ РЅРµ СѓРєР°Р·Р°Р»Рё РіРѕСЂРѕРґ");

        return Result.Success("Р’Р°Р»РёРґРЅС‹Рµ РґР°РЅРЅС‹Рµ");
    }
}
