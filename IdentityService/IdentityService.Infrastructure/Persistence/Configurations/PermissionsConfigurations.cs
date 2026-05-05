using IdentityService.Domain.Enums;
using IdentityService.Domain.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace IdentityService.Infrastructure.Persistence.Configurations;

public class PermissionsConfigurations : IEntityTypeConfiguration<Permissions>
{
    public void Configure(EntityTypeBuilder<Permissions> builder)
    {
        builder.ToTable("Permissions");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Name);
        var permission = Enum.GetValues<PermissionsEnum>().Select(x => new Permissions { Id = (int)x, Name = x.ToString() });
        builder.HasData(permission);
    }
}
