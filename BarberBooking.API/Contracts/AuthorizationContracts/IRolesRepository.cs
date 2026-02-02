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
    }
}