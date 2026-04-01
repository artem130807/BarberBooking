using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Dto.DtoSalons;
using BarberBooking.API.ExtensionsProject;
using BarberBooking.API.Filters;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Repositories
{
    public class SalonsRepository : ISalonsRepository
    {
        private readonly BarberBookingDbContext _context;
        public SalonsRepository(BarberBookingDbContext context)
        {
            _context = context;
        }

        public async Task<Salons> Add(Salons salon)
        {
            _context.Salons.Add(salon);
            return salon;
        }

        public async Task Delete(Guid Id)
        {
            await _context.Salons.Where(x => x.Id == Id).ExecuteDeleteAsync();
        }

        public async Task<PagedResult<Salons>> GetActiveSalons(string city, PageParams pageParams)
        {
            return await _context.Salons.Where(x => x.Address.City == city && x.IsActive == true).ToPagedAsync(pageParams);
        }

        public async Task<Salons> GetSalonById(Guid Id)
        {
            return await _context.Salons.FindAsync(Id);
        }

        public async Task<List<Salons>> GetSalons()
        {
            return await _context.Salons.ToListAsync();
        }

        public async Task<PagedResult<Salons>> GetSalonsByCity(string city, PageParams pageParams)
        {
            return await _context.Salons.Where(x => x.Address.City == city).ToPagedAsync(pageParams);
        }

        public async Task<PagedResult<Salons>> GetSalonsByFilter(string city, SalonFilter salonFilter, PageParams pageParams)
        {
            return await _context.Salons.Where(x => x.Address.City == city).SalonFilter(salonFilter).ToPagedAsync(pageParams);
        }

        public async Task<PagedResult<Salons>> GetSalonsByServiceName(string serviceName, string city, PageParams pageParams)
        {
            var salonIdsWithService = await _context.Sevices
            .Where(x => x.Name == serviceName)
            .Select(x => x.SalonId)
            .Distinct()
            .ToListAsync();

            var query = _context.Salons
            .Include(x => x.Services)
            .Where(x => x.Address.City == city && salonIdsWithService.Contains(x.Id));
            var pagedResult = await query.ToPagedAsync(pageParams);
            return pagedResult;
        }

        public async Task<PagedResult<Salons>> GetSalonsMinPrice(string city, PageParams pageParams)
        {
            return await _context.Salons
            .Include(x => x.Services)
            .Where(s => s.Address.City == city)
            .Select(s => new
            {
                Salon = s,
                MinPrice = s.Services.Min(service => service.Price.Value)
            })
            .OrderBy(x => x.MinPrice)
            .Select(x => x.Salon)
            .ToPagedAsync(pageParams);
        }

        public async Task<List<Salons>> GetSalonsMonthStats(int year, int month, CancellationToken cancellationToken = default)
        {
            var start = new DateTime(year, month, 1, 0, 0, 0, DateTimeKind.Utc);
            var end = start.AddMonths(1);

            return await _context.Salons
                .AsSplitQuery()
                .Include(s => s.Appointments.Where(a => a.AppointmentDate >= start && a.AppointmentDate < end))
                .ToListAsync(cancellationToken);
        }
        public async Task<List<Salons>> GetSalonsDayStats(int year, int month, int day,CancellationToken cancellationToken = default)
        {
            var start = new DateTime(year, month, day, 0, 0, 0, DateTimeKind.Utc);
            var end = start.AddDays(1);

            return await _context.Salons
                .AsSplitQuery()
                .Include(s => s.Appointments.Where(a => a.AppointmentDate >= start && a.AppointmentDate < end))
                .ToListAsync(cancellationToken);
        }

        public async Task<PagedResult<Salons>> GetSalonsNameStartWith(SearchFilterParams searchParams, PageParams pageParams)
        {
            return await _context.Salons.Where(x => x.Address.City == searchParams.City).SearchFilter(searchParams).ToPagedAsync(pageParams);
        }

       
        public async Task<Salons?> GetSalonStats(Guid salonId)
        {
            return await _context.Salons
                .AsNoTracking()
                .AsSplitQuery()
                .Include(s => s.SalonUsers)
                .Include(s => s.Services)
                .Include(s => s.Appointments)
                .Include(s => s.Reviews)
                .FirstOrDefaultAsync(s => s.Id == salonId);
        }


        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
        public async Task UpdateAsync(Salons salon)
        {
            _context.Salons.Update(salon);
            await _context.SaveChangesAsync();
        }
    }
}