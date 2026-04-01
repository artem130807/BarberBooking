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
    public class PermissionsRepository:IPermissionsRepository
    {
        private readonly BarberBookingDbContext _context;
        public PermissionsRepository(BarberBookingDbContext context)
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