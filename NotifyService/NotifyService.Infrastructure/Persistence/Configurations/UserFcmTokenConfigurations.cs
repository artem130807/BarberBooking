using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using NotifyService.Domain.Models;

namespace NotifyService.Infrastructure.Persistence.Configurations;

public class UserFcmTokenConfigurations : IEntityTypeConfiguration<UserFcmToken>
{
    public void Configure(EntityTypeBuilder<UserFcmToken> builder)
    {
        builder.ToTable("UserFcmTokens");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Token).HasMaxLength(4096);
        builder.HasIndex(x => x.Token).IsUnique();
        builder.HasIndex(x => x.UserId);
    }
}
