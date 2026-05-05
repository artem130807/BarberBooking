using Microsoft.EntityFrameworkCore;
using NotifyService.Application.Contracts;
using NotifyService.Domain.Models;

namespace NotifyService.Infrastructure.Persistence.Repositories;

public class UserFcmTokenRepository : IUserFcmTokenRepository
{
    private readonly NotifyDbContext _db;

    public UserFcmTokenRepository(NotifyDbContext db)
    {
        _db = db;
    }

    public async Task UpsertTokenAsync(Guid userId, string token, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(token))
            return;

        var normalized = token.Trim();
        var existing = await _db.UserFcmTokens
            .FirstOrDefaultAsync(x => x.Token == normalized, cancellationToken);

        var now = DateTime.UtcNow;
        if (existing != null)
        {
            existing.UserId = userId;
            existing.UpdatedAt = now;
        }
        else
        {
            _db.UserFcmTokens.Add(new UserFcmToken
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                Token = normalized,
                UpdatedAt = now
            });
        }

        await _db.SaveChangesAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<string>> GetTokensForUserAsync(Guid userId,
        CancellationToken cancellationToken = default)
    {
        return await _db.UserFcmTokens.AsNoTracking()
            .Where(x => x.UserId == userId)
            .Select(x => x.Token)
            .ToListAsync(cancellationToken);
    }

    public async Task RemoveTokenAsync(Guid userId, string token, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(token))
            return;

        var normalized = token.Trim();
        var row = await _db.UserFcmTokens
            .FirstOrDefaultAsync(x => x.UserId == userId && x.Token == normalized, cancellationToken);
        if (row != null)
        {
            _db.UserFcmTokens.Remove(row);
            await _db.SaveChangesAsync(cancellationToken);
        }
    }
}
