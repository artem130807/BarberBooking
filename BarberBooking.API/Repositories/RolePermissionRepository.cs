using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API;
using BarberBooking.API.Contracts;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Repositories
{
    public class RolePermissionRepository : IRolePermissionRepository
    {
        private readonly BarberBookingDbContext _context;
        
        public RolePermissionRepository(BarberBookingDbContext context)
        {
            _context = context;
        }
        public async Task<List<RolePermissionsEntity>> GetPermissionIdByRoleId(int roleId)
        {
            return  await _context.RolePermissions.Where(x => x.RoleId == roleId).ToListAsync();
        }
    }
}