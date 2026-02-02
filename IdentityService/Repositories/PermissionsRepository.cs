using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityService.Contracts;
using IdentityService.Models;
using Microsoft.EntityFrameworkCore;

namespace IdentityService.Repositories
{
    public class PermissionsRepository:IPermissionsRepository
    {
        private readonly IdentityDbContext _context;
        public PermissionsRepository(IdentityDbContext context)
        {
            _context = context;
        }

        public async Task<List<Permissions>> GetPermissionsById(List<int> permissionId)
        {
            if (permissionId == null || !permissionId.Any())
                return new List<Permissions>();

            return await _context.Permissions
            .Where(x => permissionId.Contains(x.Id))
            .ToListAsync();
        }
    }
}