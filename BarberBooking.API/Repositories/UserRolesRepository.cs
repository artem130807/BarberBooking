using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API;
using BarberBooking.API.Contracts;
using BarberBooking.API.Enums;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Repositories
{
    public class UserRolesRepository:IUserRolesRepository
    {
        private readonly BarberBookingDbContext _context;
        public UserRolesRepository(BarberBookingDbContext context)
        {
            _context = context;
        }

        public async Task<List<UserRoles>> GetRolesIdByUserId(Guid userId)
        {
            return await _context.UserRoles.Where(x => x.UserId == userId).ToListAsync();
        }

        public async Task<List<Roles>> GetUserRolesAsync(int roleId)
        {
           return await _context.Roles.Where(x => x.Id == roleId).ToListAsync();
        }

        public async Task AddUserRoleAsync(Guid userId, int roleId)
        {
            await _context.UserRoles.AddAsync(new UserRoles { UserId = userId, RoleId = roleId });
        }

        public async Task RemoveUserRoleAsync(Guid userId, int roleId)
        {
            var userRole = await _context.UserRoles
                .FirstOrDefaultAsync(x => x.UserId == userId && x.RoleId == roleId);
            if (userRole != null)
                _context.UserRoles.Remove(userRole);
        }

        public async Task<int> GetMaxRole(Guid userId)
        {
            return await _context.UserRoles.Where(x => x.UserId == userId).Select(x => x.RoleId).MaxAsync();
        }
    }
}