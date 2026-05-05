namespace IdentityService.Application.Dto.Users;

public class DtoLoginUser
{
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string Devices { get; set; } = string.Empty;
}
