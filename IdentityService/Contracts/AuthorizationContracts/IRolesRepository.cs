using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityService.Enums;
using IdentityService.Models;

namespace IdentityService.Contracts
{
    public interface IRolesRepository
    {
        Task<List<UserRoles>> GetRolesIdByUserId(Guid userId);
        Task<List<Roles>> GetUserRolesAsync(int roleId);
        Task AddUserRoleAsync(Guid userId, int roleId);
        Task RemoveUserRoleAsync(Guid userId, int roleId);
        Task<int> GetMaxRole(Guid userId);
    }
}