using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Enums;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts
{
    public interface IUserRolesRepository
    {
        Task<List<UserRoles>> GetRolesIdByUserId(Guid userId);
        Task<List<Roles>> GetUserRolesAsync(int roleId);
        
        /// <summary>Все роли пользователя одним запросом (без N+1 при выдаче JWT).</summary>
        Task<List<Roles>> GetAllRolesForUserAsync(Guid userId);
        Task AddUserRoleAsync(Guid userId, int roleId);
        Task RemoveUserRoleAsync(Guid userId, int roleId);
        Task<int> GetMaxRole(Guid userId);
    }
}