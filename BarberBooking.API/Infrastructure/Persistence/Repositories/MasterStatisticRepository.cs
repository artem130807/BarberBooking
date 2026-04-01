using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.ExtensionsProject;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.Master;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Repositories
{
    public class MasterStatisticRepository : IMasterStatisticRepository
    {
        private readonly BarberBookingDbContext _context;

        public MasterStatisticRepository(BarberBookingDbContext context)
        {
            _context = context;
        }

        public async Task Add(MasterStatistic masterStatistic)
        {
            _context.MasterStatistics.Add(masterStatistic);
            await Task.CompletedTask;
        }

        public async Task AddRange(List<MasterStatistic> masterStatistics)
        {
            _context.MasterStatistics.AddRange(masterStatistics);
            await Task.CompletedTask;
        }

        public async Task<PagedResult<MasterStatistic>> GetMasterStatistics(Guid masterProfileId, PageParams pageParams)
        {
            return await _context.MasterStatistics
                .Where(x => x.MasterProfileId == masterProfileId)
                .OrderByDescending(x => x.CreatedAt)
                .ToPagedAsync(pageParams);
        }

        public async Task<MasterStatistic?> GetMasterStatisticById(Guid id)
        {
            return await _context.MasterStatistics.FindAsync(id);
        }

        public async Task<HashSet<Guid>> GetMasterProfileIdsWithStatisticForDayAsync(
            int year,
            int month,
            int day,
            CancellationToken cancellationToken = default)
        {
            var ids = await _context.MasterStatistics
                .AsNoTracking()
                .Where(x => x.CreatedAt.Year == year && x.CreatedAt.Month == month && x.CreatedAt.Day == day)
                .Select(x => x.MasterProfileId)
                .ToListAsync(cancellationToken);
            return ids.ToHashSet();
        }

        public async Task<List<MasterStatistic>> GetMasterStatisticsWeekByMasterProfileId(
            Guid masterProfileId,
            MasterStatisticsParams statisticsParams)
        {
            var anchor = DateTime.SpecifyKind(
                statisticsParams.Date.ToDateTime(TimeOnly.MinValue),
                DateTimeKind.Utc);
            var daysSinceMonday = ((int)anchor.DayOfWeek + 6) % 7;
            var monday = anchor.Date.AddDays(-daysSinceMonday);
            var endExclusive = monday.AddDays(7);

            return await _context.MasterStatistics
                .AsNoTracking()
                .Where(x => x.MasterProfileId == masterProfileId
                    && x.CreatedAt >= monday
                    && x.CreatedAt < endExclusive)
                .ToListAsync();
        }

        public async Task<List<MasterStatistic>> GetMasterStatisticsMounthByMasterProfileId(
            Guid masterProfileId,
            int mounth,
            DateOnly date)
        {
            var year = date.Year;
            return await _context.MasterStatistics
                .AsNoTracking()
                .Where(x => x.MasterProfileId == masterProfileId
                    && x.CreatedAt.Year == year
                    && x.CreatedAt.Month == mounth)
                .ToListAsync();
        }

        public async Task<List<MasterStatistic>> GetMasterStatisticsYearByMasterProfileId(Guid masterProfileId, DateOnly date)
        {
            var year = date.Year;
            return await _context.MasterStatistics
                .AsNoTracking()
                .Where(x => x.MasterProfileId == masterProfileId && x.CreatedAt.Year == year)
                .ToListAsync();
        }
    }
}
