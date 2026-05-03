using IdentityService.Enums;
using Microsoft.AspNetCore.Authorization;

namespace IdentityService.Authorization;

public class PermissionRequirement(PermissionsEnum[] permissions) : IAuthorizationRequirement
{
    public PermissionsEnum[] Permissions = permissions;
}
