using IdentityService.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace IdentityService.Configurations;

public class UserFcmTokenConfigurations : IEntityTypeConfiguration<UserFcmToken>
{
    public void Configure(EntityTypeBuilder<UserFcmToken> builder)
    {
        builder.ToTable("UserFcmTokens");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Token).IsRequired().HasMaxLength(512);
        builder.Property(x => x.UpdatedAt).IsRequired();
        builder.HasIndex(x => x.Token).IsUnique();
        builder.HasIndex(x => x.UserId);
        builder.HasOne(x => x.User)
            .WithMany(x => x.UserFcmTokens)
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
