using IdentityService.Application.Contracts;
using IdentityService.Application.Records;

namespace IdentityService.Infrastructure.Auth;

public class PasswordValidatorService : IPasswordValidatorService
{
    public Task<PasswordValidationResult> ValidatePasswordAsync(string password)
    {
        if (string.IsNullOrWhiteSpace(password))
            return Task.FromResult(PasswordValidationResult.Failure("РџР°СЂРѕР»СЊ РЅРµ РјРѕР¶РµС‚ Р±С‹С‚СЊ РїСѓСЃС‚С‹Рј"));
        if (password.Length < 8)
            return Task.FromResult(PasswordValidationResult.Failure("РџР°СЂРѕР»СЊ РґРѕР»Р¶РµРЅ СЃРѕРґРµСЂР¶Р°С‚СЊ РјРёРЅРёРјСѓРј 8 СЃРёРјРІРѕР»РѕРІ"));
        if (!password.Any(char.IsUpper))
            return Task.FromResult(PasswordValidationResult.Failure("РџР°СЂРѕР»СЊ РґРѕР»Р¶РµРЅ СЃРѕРґРµСЂР¶Р°С‚СЊ С…РѕС‚СЏ Р±С‹ РѕРґРЅСѓ Р·Р°РіР»Р°РІРЅСѓСЋ Р±СѓРєРІСѓ"));
        if (!password.Any(char.IsLower))
            return Task.FromResult(PasswordValidationResult.Failure("РџР°СЂРѕР»СЊ РґРѕР»Р¶РµРЅ СЃРѕРґРµСЂР¶Р°С‚СЊ С…РѕС‚СЏ Р±С‹ РѕРґРЅСѓ СЃС‚СЂРѕС‡РЅСѓСЋ Р±СѓРєРІСѓ"));
        if (!password.Any(char.IsDigit))
            return Task.FromResult(PasswordValidationResult.Failure("РџР°СЂРѕР»СЊ РґРѕР»Р¶РµРЅ СЃРѕРґРµСЂР¶Р°С‚СЊ С…РѕС‚СЏ Р±С‹ РѕРґРЅСѓ С†РёС„СЂСѓ"));

        return Task.FromResult(PasswordValidationResult.Success());
    }
}
