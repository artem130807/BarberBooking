using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Repositories
{
    public class ServicesRepository:IServicesRepository
    {
        private readonly BarberBookingDbContext _dbContext;
        public ServicesRepository(BarberBookingDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<Services> CreateAsync(Services service)
        {
            _dbContext.Sevices.Add(service);
            return service;
        }

        public async Task<Services> DeleteAsync(Guid id)
        {
            var service = await _dbContext.Sevices.FindAsync(id);
            await _dbContext.Sevices.Where(x => x.Id == id).ExecuteDeleteAsync();
            return service;
        }

        public async Task<List<Services>> GetActiveBySalonAsync(Guid salonId)
        {
            return await _dbContext.Sevices
            .Where(x => x.SalonId == salonId && x.IsActive)
            .ToListAsync();
        }

        public async Task<Services?> GetByIdAsync(Guid id)
        {
            return await _dbContext.Sevices.FindAsync(id);
        }

        public async Task<List<Services>> GetBySalonAsync(Guid salonId)
        {
            return await _dbContext.Sevices
            .Where(x => x.SalonId == salonId)
            .ToListAsync();
        }

      
    }
}