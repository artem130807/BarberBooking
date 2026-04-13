using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.SalonsAdminContracts;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Infrastructure.Persistence.Repositories
{
    public class SalonsAdminRepository:ISalonsAdminRepository
    {
        private readonly BarberBookingDbContext _context;
        public SalonsAdminRepository(BarberBookingDbContext context)
        {
            _context = context;
        }
        public async Task Add(SalonsAdmin salonsAdmin)
        {
            _context.SalonsAdmins.Add(salonsAdmin);
        }

        public async Task Delete(Guid Id)
        {
            await _context.SalonsAdmins
            .Where(x => x.Id == Id)
            .ExecuteDeleteAsync();
        }

        public async Task<SalonsAdmin> GetById(Guid Id)
        {
            return await _context.SalonsAdmins
            .Include(x => x.Salon)
            .Include(x => x.User)
            .FirstOrDefaultAsync(x => x.Id == Id);
        }

        public async Task<List<SalonsAdmin>> GetSalonsAdmin(Guid userId)
        {
            return await _context.SalonsAdmins
            .Include(x => x.Salon)
            .Include(x => x.User)
            .Where(x => x.UserId == userId)
            .ToListAsync();
        }
    }
}