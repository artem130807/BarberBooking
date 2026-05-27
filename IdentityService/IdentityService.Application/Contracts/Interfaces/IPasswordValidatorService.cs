using IdentityService.Application.Records;

namespace IdentityService.Application.Contracts;

public interface IPasswordValidatorService
{
    Task<PasswordValidationResult> ValidatePasswordAsync(string password);
}
