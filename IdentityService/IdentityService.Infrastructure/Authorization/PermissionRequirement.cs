using IdentityService.Domain.Enums;
using Microsoft.AspNetCore.Authorization;

namespace IdentityService.Infrastructure.Authorization;

public class PermissionRequirement(PermissionsEnum[] permissions) : IAuthorizationRequirement
{
    public PermissionsEnum[] Permissions { get; } = permissions;
}
