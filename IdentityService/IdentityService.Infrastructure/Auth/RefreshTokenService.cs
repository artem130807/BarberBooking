using IdentityService.Application.Contracts;
using IdentityService.Domain.Models;

namespace IdentityService.Infrastructure.Auth;

public class RefreshTokenService : IRefreshTokenService
{
    private readonly IRefreshTokenRepository _refreshTokenRepository;
    private readonly IGenerateByteArrayService _generateByteArrayService;

    public RefreshTokenService(IRefreshTokenRepository refreshTokenRepository, IGenerateByteArrayService generateByteArrayService)
    {
        _refreshTokenRepository = refreshTokenRepository;
        _generateByteArrayService = generateByteArrayService;
    }

    public async Task<byte[]> CreateToken(Guid userId, string devices)
    {
        var array = _generateByteArrayService.GenerateByteArray();
        var refreshToken = RefreshToken.Create(userId, array, devices);
        await _refreshTokenRepository.Add(refreshToken.Value);
        await _refreshTokenRepository.SaveChangesAsync();
        return array;
    }

    public async Task RevokedToken(Guid userId, string devices)
    {
        var token = await _refreshTokenRepository.GetRefreshTokenByDevices(userId, devices);
        if (token != null)
            token.RevokedToken();
        await _refreshTokenRepository.SaveChangesAsync();
    }
}
