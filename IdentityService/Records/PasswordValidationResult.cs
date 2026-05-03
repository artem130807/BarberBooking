namespace IdentityService.Records;

public record PasswordValidationResult(bool IsValid, string Error)
{
    public static PasswordValidationResult Success() => new(true, string.Empty);
    public static PasswordValidationResult Failure(string error) => new(false, error);
}
