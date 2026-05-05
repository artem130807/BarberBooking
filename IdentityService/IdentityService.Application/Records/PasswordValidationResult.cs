namespace IdentityService.Application.Records;

public record PasswordValidationResult
{
    public bool IsValid { get; set; }
    public string Message { get; set; } = string.Empty;

    public static PasswordValidationResult Failure(string message) => new() { IsValid = false, Message = message };
    public static PasswordValidationResult Success() => new() { IsValid = true, Message = string.Empty };
}
