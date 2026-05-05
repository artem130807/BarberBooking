using IdentityService.Domain.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace IdentityService.Infrastructure.Persistence.Configurations;

public class UsersConfigurations : IEntityTypeConfiguration<Users>
{
    public void Configure(EntityTypeBuilder<Users> builder)
    {
        builder.ToTable("Users");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Name);
        builder.ComplexProperty(c => c.Phone, c =>
        {
            c.IsRequired();
            c.Property(e => e.Number).HasColumnName("Phone").HasMaxLength(255);
        });
        builder.Property(x => x.Email).IsRequired();
        builder.Property(x => x.PasswordHash);
        builder.Property(x => x.City).IsRequired();
        builder.HasMany(x => x.Roles).WithMany(x => x.Users).UsingEntity<UserRoles>(
            x => x.HasOne<Roles>().WithMany().HasForeignKey(x => x.RoleId),
            x => x.HasOne<Users>().WithMany().HasForeignKey(x => x.UserId));
        builder.HasMany(x => x.RefreshTokens).WithOne(x => x.User).HasForeignKey(x => x.UserId);
    }
}
