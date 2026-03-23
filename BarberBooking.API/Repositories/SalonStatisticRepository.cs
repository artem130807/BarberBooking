using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Filters;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Repositories
{
    public class SalonStatisticRepository : ISalonStatisticRepository
    {
        private readonly BarberBookingDbContext _context;
        public SalonStatisticRepository(BarberBookingDbContext context)
        {
            _context = context;
        }
        public async Task AddRange(List<Models.SalonStatistic> salonStatistics)
        {
            _context.SalonStatistics.AddRange(salonStatistics);
            await Task.CompletedTask;
        }
        public async Task Add(Models.SalonStatistic salonStatistic)
        {
            _context.SalonStatistics.Add(salonStatistic);
            await Task.CompletedTask;
        }

        public async Task<PagedResult<Models.SalonStatistic>> GetSalonStatisctics(Guid salonId, PageParams pageParams)
        {
            return await _context.SalonStatistics.Where(x => x.SalonId == salonId).ToPagedAsync(pageParams);
        }

        public async Task<Models.SalonStatistic?> GetSalonStatistic(Guid id)
        {
            return await _context.SalonStatistics.FindAsync(id);
        }

        public async Task<HashSet<Guid>> GetSalonIdsWithStatisticForMonthAsync(int year, int month, CancellationToken cancellationToken = default)
        {
             var ids = await _context.SalonStatistics
                .AsNoTracking()
                .Where(x => x.CreatedAt.Year == year && x.CreatedAt.Month == month)
                .Select(x => x.SalonId)
                .ToListAsync(cancellationToken);
            return ids.ToHashSet();
        }
    }
}
