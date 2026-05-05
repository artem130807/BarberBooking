using CSharpFunctionalExtensions;

namespace IdentityService.Domain.Models;

public class RefreshToken
{
    public Guid Id { get; private set; }
    public string TokenHash { get; private set; } = string.Empty;
    public Guid UserId { get; private set; }
    public Users User { get; private set; } = null!;
    public DateTime ExpiresAt { get; private set; }
    public bool IsRevoked { get; private set; }
    public string Devices { get; private set; } = string.Empty;

    public static Result<RefreshToken> Create(Guid userId, byte[] array, string devices)
    {
        var refreshToken = Convert.ToBase64String(array);
        return new RefreshToken
        {
            Id = Guid.NewGuid(),
            TokenHash = refreshToken,
            UserId = userId,
            ExpiresAt = DateTime.UtcNow.AddDays(180),
            IsRevoked = false,
            Devices = devices
        };
    }

    public void RevokedToken() => IsRevoked = true;
}
