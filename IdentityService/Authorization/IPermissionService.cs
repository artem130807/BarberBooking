using IdentityService.Enums;

namespace IdentityService.Authorization;

public interface IPermissionService
{
    Task<HashSet<PermissionsEnum>> GetPermissionsAsync(Guid userId);
}
