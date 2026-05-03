using IdentityService.Records;

namespace IdentityService.Contracts;

public interface IPasswordValidatorService
{
    Task<PasswordValidationResult> ValidatePasswordAsync(string password);
}
