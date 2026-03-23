using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Filters.Salon;
using BarberBooking.API.Migrations;

namespace BarberBooking.API.ExtensionsProject
{
    public static class SalonStatisticsExtensions
    {
        public static IQueryable<Models.SalonStatistic> StatisticFilter(this IQueryable<Models.SalonStatistic> query, SalonStatisticsFilter filter)
        {
            if(filter.SalonId.HasValue)
                query = query.Where(x => x.SalonId == filter.SalonId);
            if(filter.Mounth.HasValue)
                query = query.Where(x => x.CreatedAt.Month == filter.Mounth);
            if (filter.Date.HasValue)
            {
                var targetDate = filter.Date.Value.ToDateTime(TimeOnly.MinValue);
                query = query.Where(x => x.CreatedAt.Date == targetDate.Date);
            }
            return query;
        }
    }
}