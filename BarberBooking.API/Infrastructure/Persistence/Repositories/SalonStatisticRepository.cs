using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.ExtensionsProject;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.Salon;
using BarberBooking.API.Models;
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
        public async Task<HashSet<Guid>> GetSalonIdsWithStatisticForDayAsync(int year, int month, int day,CancellationToken cancellationToken = default)
        {
             var ids = await _context.SalonStatistics
                .AsNoTracking()
                .Where(x => x.CreatedAt.Year == year && x.CreatedAt.Month == month && x.CreatedAt.Day == day)
                .Select(x => x.SalonId)
                .ToListAsync(cancellationToken);
            return ids.ToHashSet();
        }

        public async Task<List<SalonStatistic>> GetSalonStatisticsByFilter(SalonStatisticsFilter filter, string city)
        {
            return await _context.SalonStatistics.Where(x => x.Salon.Address.City == city).StatisticFilter(filter).ToListAsync();
        }

        public async Task<List<SalonStatistic>> GetSalonStatisticsWeekBySalonId(Guid salonId, SalonStatisticsParams salonStatisticsParams)
        {
            var anchor = DateTime.SpecifyKind(
                salonStatisticsParams.Date.ToDateTime(TimeOnly.MinValue),
                DateTimeKind.Utc);
            var daysSinceMonday = ((int)anchor.DayOfWeek + 6) % 7;
            var monday = anchor.Date.AddDays(-daysSinceMonday);
            var endExclusive = monday.AddDays(7);

            return await _context.SalonStatistics
                .AsNoTracking()
                .Where(x => x.SalonId == salonId
                    && x.CreatedAt >= monday
                    && x.CreatedAt < endExclusive)
                .ToListAsync();
        }

        public async Task<List<SalonStatistic>> GetSalonStatisticsMounthBySalonId(Guid salonId, int mounth, DateOnly date)
        {
            var year = date.Year;
            return await _context.SalonStatistics
                .AsNoTracking()
                .Where(x => x.SalonId == salonId
                    && x.CreatedAt.Year == year
                    && x.CreatedAt.Month == mounth)
                .ToListAsync();
        }

        public async Task<List<SalonStatistic>> GetSalonStatisticsYearBySalonId(Guid salonId, DateOnly date)
        {
            var year = date.Year;
            return await _context.SalonStatistics
                .AsNoTracking()
                .Where(x => x.SalonId == salonId && x.CreatedAt.Year == year)
                .ToListAsync();
        }
    }
}
