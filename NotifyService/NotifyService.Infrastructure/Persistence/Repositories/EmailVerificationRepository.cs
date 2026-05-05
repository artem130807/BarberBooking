using Microsoft.EntityFrameworkCore;
using NotifyService.Application.Contracts;
using NotifyService.Domain.Models;

namespace NotifyService.Infrastructure.Persistence.Repositories;

public sealed class EmailVerificationRepository : IEmailVerificationRepository
{
    private readonly NotifyDbContext _context;

    public EmailVerificationRepository(NotifyDbContext context)
    {
        _context = context;
    }

    public Task Add(EmailVerification emailVerification)
    {
        _context.EmailVerifications.Add(emailVerification);
        return Task.CompletedTask;
    }

    public Task Delete(string Email) =>
        _context.EmailVerifications.Where(x => x.Email == Email).ExecuteDeleteAsync();

    public async Task<EmailVerification?> GetActiveUnusedCodeByEmail(string email) =>
        await _context.EmailVerifications
            .Where(x => x.Email == email && !x.IsUsed && x.ExpiresAt > DateTime.UtcNow)
            .OrderByDescending(x => x.LastSentAt)
            .FirstOrDefaultAsync();

    public async Task<EmailVerification?> GetEmailVerificationByEmail(string Email) =>
        await _context.EmailVerifications.FirstOrDefaultAsync(x => x.Email == Email);

    public async Task<EmailVerification?> GetVerificationByCodeAndEmail(string Code, string Email) =>
        await _context.EmailVerifications
            .Where(x => x.Code == Code && x.Email == Email && !x.IsUsed)
            .OrderByDescending(x => x.ExpiresAt)
            .FirstOrDefaultAsync();

    public async Task<List<EmailVerification>> GetVerifications()
    {
        var cutoffTime = DateTime.UtcNow.AddMinutes(-15);
        return await _context.EmailVerifications.Where(x => x.LastSentAt <= cutoffTime).ToListAsync();
    }

    public Task RemoveRange(List<EmailVerification> emailVerifications)
    {
        _context.EmailVerifications.RemoveRange(emailVerifications);
        return Task.CompletedTask;
    }

    public Task SaveChangesAsync() => _context.SaveChangesAsync();
}
