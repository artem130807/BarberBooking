using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.Master;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts.MasterProfileContracts
{
    public interface IMasterStatisticRepository
    {
        Task Add(MasterStatistic masterStatistic);
        Task AddRange(List<MasterStatistic> masterStatistics);
        Task<PagedResult<MasterStatistic>> GetMasterStatistics(Guid masterProfileId, PageParams pageParams);
        Task<MasterStatistic?> GetMasterStatisticById(Guid id);
        Task<HashSet<Guid>> GetMasterProfileIdsWithStatisticForDayAsync(
            int year,
            int month,
            int day,
            CancellationToken cancellationToken = default);
        Task<List<MasterStatistic>> GetMasterStatisticsWeekByMasterProfileId(
            Guid masterProfileId,
            MasterStatisticsParams statisticsParams);
        Task<List<MasterStatistic>> GetMasterStatisticsMounthByMasterProfileId(Guid masterProfileId, int mounth, DateOnly date);
        Task<List<MasterStatistic>> GetMasterStatisticsYearByMasterProfileId(Guid masterProfileId, DateOnly date);
    }
}
