using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Filters.Services;
using BarberBooking.API.Models;

namespace BarberBooking.API.ExtensionsProject
{
    public static class ServicesExtensions
    {
        public static IQueryable<Services>  SearchFilter(this IQueryable<Services> query, SearchServicesParams searchParams)
        {
             if (!string.IsNullOrWhiteSpace(searchParams.ServiceName))
                query = query.Where(x => x.Salon.Address.City ==  searchParams.City && x.Name.StartsWith(searchParams.ServiceName));
            return query;
        }
    }
}