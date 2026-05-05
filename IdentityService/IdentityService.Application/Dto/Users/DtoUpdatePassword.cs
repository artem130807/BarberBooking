namespace IdentityService.Application.Dto.Users;

public class DtoUpdatePassword
{
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
}
