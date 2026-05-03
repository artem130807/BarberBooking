using IdentityService.Enums;
using Microsoft.AspNetCore.Authorization;

namespace IdentityService.Authorization;

public class RequirePermissionAttribute : AuthorizeAttribute
{
    public RequirePermissionAttribute(params PermissionsEnum[] permissions)
    {
        Policy = string.Join(",", permissions.Select(p => p.ToString()));
    }
}
