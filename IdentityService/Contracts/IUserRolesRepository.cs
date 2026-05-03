using IdentityService.Models;

namespace IdentityService.Contracts;

public interface IUserRolesRepository
{
    Task<List<UserRoles>> GetRolesIdByUserId(Guid userId);
    Task<List<Roles>> GetUserRolesAsync(int roleId);
    Task AddUserRoleAsync(Guid userId, int roleId);
    Task RemoveUserRoleAsync(Guid userId, int roleId);
    Task<int> GetMaxRole(Guid userId);
}
