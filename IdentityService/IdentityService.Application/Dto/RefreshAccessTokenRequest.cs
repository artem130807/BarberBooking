namespace IdentityService.Application.Dto;

public class RefreshAccessTokenRequest
{
    public string RefreshToken { get; set; } = string.Empty;
    public string Devices { get; set; } = string.Empty;
}
