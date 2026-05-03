using CSharpFunctionalExtensions;

namespace IdentityService.Models;

public class RefreshToken
{
    public Guid Id { get; private set; }
    public string TokenHash { get; private set; }
    public Guid UserId { get; private set; }
    public Users User { get; private set; }
    public DateTime ExpiresAt { get; private set; }
    public bool IsRevoked { get; private set; }
    public string Devices { get; private set; }

    public static Result<RefreshToken> Create(Guid userId, byte[] array, string devices)
    {
        var refreshToken = GenerateRefreshToken(array);
        var result = new RefreshToken
        {
            Id = Guid.NewGuid(),
            TokenHash = refreshToken,
            UserId = userId,
            ExpiresAt = DateTime.UtcNow.AddDays(180),
            IsRevoked = false,
            Devices = devices
        };
        return result;
    }

    public void RevokedToken() => IsRevoked = true;

    private static string GenerateRefreshToken(byte[] array)
    {
        return Convert.ToBase64String(array);
    }
}
