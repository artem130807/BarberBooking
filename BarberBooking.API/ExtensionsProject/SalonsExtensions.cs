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
            if(salonFilter.IsActive.HasValue)
                query = query.Where(x => x.IsActive == salonFilter.IsActive);
            if(salonFilter.MaxRating.HasValue)
                query = query.OrderByDescending(x => x.Rating);
            if(salonFilter.Popular.HasValue)
                query = query.OrderByDescending(x => x.RatingCount);
            if (salonFilter.MinPrice.HasValue)
                query = query.Select(s => new
                {
                    Salon = s,
                    MinPrice = s.Services.Min(service => service.Price.Value)
                })
                .OrderBy(x => x.MinPrice)
                .Select(x => x.Salon);
        
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