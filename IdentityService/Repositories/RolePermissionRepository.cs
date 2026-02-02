using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityService.Authorization;
using IdentityService.Contracts;
using IdentityService.Models;
using Microsoft.EntityFrameworkCore;

namespace IdentityService.Repositories
{
    public class RolePermissionRepository : IRolePermissionRepository
    {
        private readonly IdentityDbContext _context;
        
        public RolePermissionRepository(IdentityDbContext context)
        {
            _context = context;
        }
        public async Task<List<RolePermissionsEntity>> GetPermissionIdByRoleId(int roleId)
        {
            return  await _context.RolePermissions.Where(x => x.RoleId == roleId).ToListAsync();
        }
    }
}