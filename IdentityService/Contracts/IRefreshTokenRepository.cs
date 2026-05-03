using IdentityService.Models;

namespace IdentityService.Contracts;

public interface IRefreshTokenRepository
{
    Task Add(RefreshToken refreshToken);
    Task Delete(Guid id);
    Task<RefreshToken?> GetRefreshTokenByDevices(Guid userId, string devices);
    Task<RefreshToken?> GetRefreshTokenByToken(string token);
    Task<RefreshToken?> GetRefreshToken(Guid id);
    Task<List<RefreshToken>> GetRefreshTokens(Guid userId);
    Task<List<RefreshToken>> GetRefreshRevokedTokens(Guid userId);
    Task SaveChangesAsync();
}
