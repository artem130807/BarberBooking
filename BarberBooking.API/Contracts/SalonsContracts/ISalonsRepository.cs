using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoSalons;
using BarberBooking.API.Filters;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts.SalonsContracts
{
    public interface ISalonsRepository
    {
        Task<Salons> Add(Salons salon);
        Task Delete(Guid Id);
        Task<PagedResult<Salons>> GetSalonsByFilter(string city,SalonFilter salonFilter, PageParams pageParams);
        Task<PagedResult<Salons>> GetSalonsByCity(string city, PageParams pageParams);
        Task<PagedResult<Salons>> GetActiveSalons(string city, PageParams pageParams);
        Task<Salons> GetSalonById(Guid Id);
        Task<PagedResult<Salons>> GetSalonsNameStartWith(SearchFilterParams searchParams, PageParams pageParams);
        Task<PagedResult<Salons>> GetSalonsByServiceName(string serviceName, string city, PageParams pageParams);
        Task<PagedResult<Salons>> GetSalonsMinPrice(string city, PageParams pageParams);
        Task<List<Salons>> GetSalons();
        Task SaveChangesAsync();
        Task UpdateAsync(Salons salon);
        Task<Salons?> GetSalonStats(Guid salonId);

        /// <summary>Salons with appointments in the given UTC calendar month (for monthly report).</summary>
        Task<List<Salons>> GetSalonsMonthStats(int year, int month, CancellationToken cancellationToken = default);
    }
}
