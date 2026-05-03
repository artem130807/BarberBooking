using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityService.Contracts;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;
using IdentityService.Models;

namespace IdentityService.Repositories
{
    public class PermissionsRepository:IPermissionsRepository
    {
        private readonly IdentityServiceDbContext _context;
        public PermissionsRepository(IdentityServiceDbContext context)
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