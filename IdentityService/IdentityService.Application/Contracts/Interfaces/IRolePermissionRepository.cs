using IdentityService.Domain.Models;

namespace IdentityService.Application.Contracts;

public interface IRolePermissionRepository
{
    Task<List<RolePermissionsEntity>> GetPermissionIdByRoleId(int roleId);
}
