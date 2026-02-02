using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityService.Contracts;
using IdentityService.Models;
using Microsoft.EntityFrameworkCore;

namespace IdentityService.Repositories
{
    public class RolesRepository:IRolesRepository
    {
        private readonly IdentityDbContext _context;
        public RolesRepository(IdentityDbContext context)
        {
            _context = context;
        }

        public async Task<List<UserRoles>> GetRolesIdByUserId(Guid userId)
        {
            return await _context.UserRoles.Where(x => x.UserId == userId).ToListAsync();
        }
    }
}