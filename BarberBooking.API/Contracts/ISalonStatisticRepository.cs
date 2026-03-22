using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Filters;
using BarberBooking.API.Migrations;

namespace BarberBooking.API.Contracts
{
    public interface ISalonStatisticRepository
    {
        Task Add(Models.SalonStatistic salonStatistic);
        Task<PagedResult<Models.SalonStatistic>> GetSalonStatisctics(Guid salonId, PageParams pageParams);
        Task<Models.SalonStatistic> GetSalonStatistic(Guid Id);
    }
}