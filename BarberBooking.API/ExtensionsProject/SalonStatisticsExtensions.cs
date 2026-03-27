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
            if(filter.Day.HasValue)
                query = query.Where(x => x.CreatedAt.Day == filter.Day);
            return query;
        }
    }
}