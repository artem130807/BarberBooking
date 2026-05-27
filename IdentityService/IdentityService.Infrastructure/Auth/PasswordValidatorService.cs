using IdentityService.Application.Contracts;
using IdentityService.Application.Records;

namespace IdentityService.Infrastructure.Auth;

public class PasswordValidatorService : IPasswordValidatorService
{
    public Task<PasswordValidationResult> ValidatePasswordAsync(string password)
    {
        if (string.IsNullOrWhiteSpace(password))
            return Task.FromResult(PasswordValidationResult.Failure("Пароль не может быть пустым"));
        if (password.Length < 8)
            return Task.FromResult(PasswordValidationResult.Failure("Пароль должен содержать не менее 8 символов"));
        if (!password.Any(char.IsUpper))
            return Task.FromResult(PasswordValidationResult.Failure("Пароль должен содержать хотя бы одну заглавную букву"));
        if (!password.Any(char.IsLower))
            return Task.FromResult(PasswordValidationResult.Failure("Пароль должен содержать хотя бы одну строчную букву"));
        if (!password.Any(char.IsDigit))
            return Task.FromResult(PasswordValidationResult.Failure("Пароль должен содержать хотя бы одну цифру"));

        return Task.FromResult(PasswordValidationResult.Success());
    }
}
