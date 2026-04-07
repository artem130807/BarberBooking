using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.Services;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts
{
    public interface IServicesRepository
    {
        Task<Services> CreateAsync(Services service);
        Task<Services?> GetByIdAsync(Guid id);
        Task<List<Services>> GetBySalonAsync(Guid salonId);
        Task<List<Services>> GetActiveBySalonAsync(Guid salonId);
        Task<Services> DeleteAsync(Guid id);
        Task<PagedResult<Services>> GetServicesNameStartWith(SearchServicesParams searchParams, PageParams pageParams);
        Task<PagedResult<Services>> GetTopServices(Guid salonId ,PageParams pageParams);
        Task<PagedResult<Services>> GetServicesBySalonPaged(Guid salonId, PageParams pageParams);
        Task<List<Services>> GetServicesBySalon(Guid salonId);
    }
}