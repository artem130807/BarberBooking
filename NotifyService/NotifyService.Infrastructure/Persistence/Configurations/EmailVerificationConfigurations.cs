using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using NotifyService.Domain.Models;

namespace NotifyService.Infrastructure.Persistence.Configurations;

public sealed class EmailVerificationConfigurations : IEntityTypeConfiguration<EmailVerification>
{
    public void Configure(EntityTypeBuilder<EmailVerification> builder)
    {
        builder.HasKey(x => x.Id);
        builder.ToTable("EmailVerification");
        builder.Property(x => x.Email).IsRequired();
        builder.Property(x => x.Code).IsRequired();
        builder.Property(x => x.CratedDate);
        builder.Property(x => x.ExpiresAt);
        builder.Property(x => x.LastSentAt);
        builder.Property(x => x.IsUsed);
        builder.HasIndex(x => x.Email);
    }
}
