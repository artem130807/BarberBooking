using IdentityService.Domain.Enums;
using IdentityService.Domain.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace IdentityService.Infrastructure.Persistence.Configurations;

public class RolesConfigurations : IEntityTypeConfiguration<Roles>
{
    public void Configure(EntityTypeBuilder<Roles> builder)
    {
        builder.ToTable("Roles");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Name);
        builder.HasMany(x => x.Permissions).WithMany(x => x.Roles)
            .UsingEntity<RolePermissionsEntity>(
                x => x.HasOne<Permissions>().WithMany().HasForeignKey(x => x.PermissionId),
                x => x.HasOne<Roles>().WithMany().HasForeignKey(x => x.RoleId));

        var roles = Enum.GetValues<RolesEnum>().Select(x => new Roles { Id = (int)x, Name = x.ToString() });
        builder.HasData(roles);
    }
}
