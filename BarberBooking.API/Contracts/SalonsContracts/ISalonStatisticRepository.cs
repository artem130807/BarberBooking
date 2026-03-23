using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Filters;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts.SalonsContracts
{
    public interface ISalonStatisticRepository
    {
        Task Add(SalonStatistic salonStatistic);
        Task<PagedResult<SalonStatistic>> GetSalonStatisctics(Guid salonId, PageParams pageParams);
        Task<SalonStatistic?> GetSalonStatistic(Guid id);
        Task AddRange(List<SalonStatistic> salonStatistics);
        Task<HashSet<Guid>> GetSalonIdsWithStatisticForMonthAsync(int year, int month, CancellationToken cancellationToken = default);
    }
}
