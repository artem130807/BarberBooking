using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.ExtensionsProject;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.Services;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Repositories
{
    public class ServicesRepository:IServicesRepository
    {
        private readonly BarberBookingDbContext _context;
        public ServicesRepository(BarberBookingDbContext dbContext)
        {
            _context = dbContext;
        }

        public async Task<Services> CreateAsync(Services service)
        {
            _context.Sevices.Add(service);
            return service;
        }

        public async Task<Services> DeleteAsync(Guid id)
        {
            var service = await _context.Sevices.FindAsync(id);
            await _context.Sevices.Where(x => x.Id == id).ExecuteDeleteAsync();
            return service;
        }

        public async Task<List<Services>> GetActiveBySalonAsync(Guid salonId)
        {
            return await _context.Sevices
            .Where(x => x.SalonId == salonId && x.IsActive)
            .ToListAsync();
        }

        public async Task<Services?> GetByIdAsync(Guid id)
        {
            return await _context.Sevices.FindAsync(id);
        }

        public async Task<List<Services>> GetBySalonAsync(Guid salonId)
        {
            return await _context.Sevices
            .Where(x => x.SalonId == salonId)
            .ToListAsync();
        }
        public async Task<PagedResult<Services>> GetServicesNameStartWith(SearchServicesParams searchParams, PageParams pageParams)
        {
            return await _context.Sevices.Include(x => x.Salon).SearchFilter(searchParams).ToPagedAsync(pageParams);
        }
      
    }
}