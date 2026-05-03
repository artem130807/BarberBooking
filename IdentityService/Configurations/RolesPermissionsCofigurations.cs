using IdentityService.Authorization;
using IdentityService.Enums;
using IdentityService.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace IdentityService.Configurations;

public class RolesPermissionsCofigurations : IEntityTypeConfiguration<RolePermissionsEntity>
{
    private readonly AuthorizationOptions _authorizationOptions;

    public RolesPermissionsCofigurations(AuthorizationOptions authorizationOptions)
    {
        _authorizationOptions = authorizationOptions;
    }

    public void Configure(EntityTypeBuilder<RolePermissionsEntity> builder)
    {
        builder.ToTable("RolePermissions");
        builder.HasKey(x => new { x.RoleId, x.PermissionId });
        builder.HasData(ParseRolePermissions());
    }

    public List<RolePermissionsEntity> ParseRolePermissions()
    {
        return _authorizationOptions.RolePermissions.SelectMany(rp => rp.Permissions.Select(p => new RolePermissionsEntity
        {
            RoleId = (int)Enum.Parse<RolesEnum>(rp.Role),
            PermissionId = (int)Enum.Parse<PermissionsEnum>(p)
        })).ToList();
    }
}
