namespace IdentityService.Application.Contracts;

public interface IRefreshTokenService
{
    Task<byte[]> CreateToken(Guid userId, string devices);
    Task RevokedToken(Guid userId, string devices);
}
