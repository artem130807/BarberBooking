using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Filters;
using BarberBooking.API.Models;

namespace BarberBooking.API.ExtensionsProject
{
    public static class SalonsExtensions
    {
        public static IQueryable<Salons> SalonFilter(this IQueryable<Salons> query, SalonFilter salonFilter)
        {
            if (salonFilter.IsActive == true)
                query = query.Where(x => x.IsActive);
            if (salonFilter.MaxRating == true)
                query = query.OrderByDescending(x => x.Rating);
            if (salonFilter.Popular == true)
                query = query.OrderByDescending(x => x.RatingCount);
            if (salonFilter.MinPrice == true)
            {
                query = query
                    .Select(s => new
                    {
                        Salon = s,
                        MinPrice = s.Services.Min(service => (decimal?)service.Price.Value),
                    })
                    .OrderBy(x => x.MinPrice ?? decimal.MaxValue)
                    .Select(x => x.Salon);
            }
            return query;
        }
        public static IQueryable<Salons>  SearchFilter(this IQueryable<Salons> query, SearchFilterParams searchFilterParams)
        {
            if(!string.IsNullOrWhiteSpace(searchFilterParams.SalonName))
                query = query.Where(x => x.Address.City == searchFilterParams.City && x.Name.StartsWith(searchFilterParams.SalonName));
            return query;
        }
    }
}