using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.MasterServicesContracts;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Repositories
{
    public class MasterServicesRepository : IMasterServicesRepository
    {
        private readonly BarberBookingDbContext _context;

        public MasterServicesRepository(BarberBookingDbContext context)
        {
            _context = context;
        }

        public async Task<MasterServices?> GetByIdAsync(Guid id)
        {
            return await _context.MasterServices
                .Include(x => x.Service)
                .FirstOrDefaultAsync(x => x.Id == id);
        }

        public async Task<List<MasterServices>> GetByMasterProfileIdAsync(Guid masterProfileId)
        {
            return await _context.MasterServices
                .AsNoTracking()
                .Include(x => x.Service)
                .Where(x => x.MasterProfileId == masterProfileId)
                .ToListAsync();
        }

        public async Task<bool> ExistsAsync(Guid masterProfileId, Guid serviceId)
        {
            return await _context.MasterServices
                .AnyAsync(x => x.MasterProfileId == masterProfileId && x.ServiceId == serviceId);
        }

        public async Task<MasterServices> AddAsync(MasterServices entity)
        {
            await _context.MasterServices.AddAsync(entity);
            return entity;
        }

        public async Task DeleteAsync(Guid id)
        {
            var entity = await _context.MasterServices.FindAsync(id);
            if (entity != null)
                _context.MasterServices.Remove(entity);
        }
    }
}
