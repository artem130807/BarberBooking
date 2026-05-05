using Microsoft.EntityFrameworkCore;
using NotifyService.Domain.Models;
using NotifyService.Infrastructure.Persistence.Configurations;

namespace NotifyService.Infrastructure.Persistence;

public class NotifyDbContext(DbContextOptions<NotifyDbContext> options) : DbContext(options)
{
    public DbSet<UserFcmToken> UserFcmTokens => Set<UserFcmToken>();
    public DbSet<EmailVerification> EmailVerifications => Set<EmailVerification>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfiguration(new UserFcmTokenConfigurations());
        modelBuilder.ApplyConfiguration(new EmailVerificationConfigurations());
        base.OnModelCreating(modelBuilder);
    }
}
