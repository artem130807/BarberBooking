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
             if(salonFilter.MinRating.HasValue)
                query = query.Where(x => x.Rating >= salonFilter.MinRating);
            if(salonFilter.MaxRating.HasValue)
                query = query.Where(x => x.Rating <= salonFilter.MaxRating);
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