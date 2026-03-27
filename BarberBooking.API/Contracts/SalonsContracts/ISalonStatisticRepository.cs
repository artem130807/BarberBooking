using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.Salon.Queries.Handlers;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.Salon;
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
        Task<HashSet<Guid>> GetSalonIdsWithStatisticForDayAsync(int year, int month, int day,CancellationToken cancellationToken = default);
        Task<List<Models.SalonStatistic>> GetSalonStatisticsByFilter(SalonStatisticsFilter filter, string city);
        Task<List<SalonStatistic>> GetSalonStatisticsWeekBySalonId(Guid salonId, SalonStatisticsParams salonStatisticsParams);
        Task<List<SalonStatistic>> GetSalonStatisticsMounthBySalonId(Guid salonId, int mounth, DateOnly date);
        Task<List<SalonStatistic>> GetSalonStatisticsYearBySalonId(Guid salonId, DateOnly date);
    }
}
