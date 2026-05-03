using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityService.Models;
using IdentityService.Contracts;
using Microsoft.EntityFrameworkCore;

namespace IdentityService.Repositories
{
    public class RolePermissionRepository : IRolePermissionRepository
    {
        private readonly IdentityServiceDbContext _context;
        
        public RolePermissionRepository(IdentityServiceDbContext context)
        {
            _context = context;
        }
        public async Task<List<RolePermissionsEntity>> GetPermissionIdByRoleId(int roleId)
        {
            return  await _context.RolePermissions.Where(x => x.RoleId == roleId).ToListAsync();
        }
    }
}