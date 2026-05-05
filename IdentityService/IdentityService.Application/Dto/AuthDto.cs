namespace IdentityService.Application.Dto;

public class AuthDto
{
    public string AccessToken { get; set; } = string.Empty;
    public byte[]? RefreshToken { get; set; }
    public string Message { get; set; } = string.Empty;
    public int RoleInterface { get; set; }
}
