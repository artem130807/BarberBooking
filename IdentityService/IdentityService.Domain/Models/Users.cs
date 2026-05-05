using IdentityService.Domain.ValueObjects;

namespace IdentityService.Domain.Models;

public class Users
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public PhoneNumber Phone { get; set; } = null!;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public ICollection<Roles> Roles { get; set; } = new List<Roles>();
    public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();
}
