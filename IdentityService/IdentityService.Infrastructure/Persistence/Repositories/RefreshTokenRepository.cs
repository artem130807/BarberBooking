using IdentityService.Application.Contracts;
using IdentityService.Domain.Models;
using Microsoft.EntityFrameworkCore;

namespace IdentityService.Infrastructure.Persistence.Repositories;

public class RefreshTokenRepository : IRefreshTokenRepository
{
    private readonly IdentityServiceDbContext _context;

    public RefreshTokenRepository(IdentityServiceDbContext context)
    {
        _context = context;
    }

    public async Task Add(RefreshToken refreshToken)
    {
        _context.RefreshTokens.Add(refreshToken);
        await Task.CompletedTask;
    }

    public Task Delete(Guid id) =>
        _context.RefreshTokens.Where(x => x.Id == id).ExecuteDeleteAsync();

    public async Task<RefreshToken?> GetRefreshToken(Guid id) =>
        await _context.RefreshTokens.FindAsync(id);

    public async Task<List<RefreshToken>> GetRefreshTokens(Guid userId) =>
        await _context.RefreshTokens.Where(x => x.UserId == userId && !x.IsRevoked).ToListAsync();

    public async Task<List<RefreshToken>> GetRefreshRevokedTokens(Guid userId) =>
        await _context.RefreshTokens.Where(x => x.UserId == userId && x.IsRevoked).ToListAsync();

    public Task SaveChangesAsync() => _context.SaveChangesAsync();

    public async Task<RefreshToken?> GetRefreshTokenByDevices(Guid userId, string devices) =>
        await _context.RefreshTokens.FirstOrDefaultAsync(x => x.UserId == userId && x.Devices == devices && !x.IsRevoked);

    public async Task<RefreshToken?> GetRefreshTokenByToken(string token) =>
        await _context.RefreshTokens.FirstOrDefaultAsync(x => x.TokenHash == token);
}
