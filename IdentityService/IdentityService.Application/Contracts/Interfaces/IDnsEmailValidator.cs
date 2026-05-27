using CSharpFunctionalExtensions;

namespace IdentityService.Application.Contracts;

public interface IDnsEmailValidator
{
    Task<Result> ValidateEmailAsync(string Email);
}
