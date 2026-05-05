namespace IdentityService.Application.Dto.Users;

public class DtoUserProfile
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public DtoPhone Phone { get; set; } = new();
    public string Email { get; set; } = string.Empty;
}
