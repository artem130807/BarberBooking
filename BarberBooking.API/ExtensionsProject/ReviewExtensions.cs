using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Filters.ReviewFilters;
using BarberBooking.API.Models;

namespace BarberBooking.API.ExtensionsProject
{
    public static class ReviewExtensions
    {
        public static IQueryable<Review> FilterReviewSalon(this IQueryable<Review> query, ReviewSort reviewSort)
        {
            if (reviewSort.OrderBy.HasValue)
            {
                query = query.OrderBy(x => x.SalonRating)
                .ThenBy(x => x.MasterRating)
                .ThenByDescending(x => x.CreatedAt);
            }
            else if (reviewSort.OrderbyDescending.HasValue)
            {
                query = query.OrderByDescending(x => x.SalonRating)
                .ThenByDescending(x => x.MasterRating)
                .ThenByDescending(x => x.CreatedAt);
            }
            else
            {
                query = query.OrderByDescending(x => x.CreatedAt);
            }
            return query;
        }
        public static IQueryable<Review> FilterReviewMaster(this IQueryable<Review> query, ReviewSort reviewSort)
        {
            if (reviewSort.OrderBy.HasValue)
            {
                query = query.OrderBy(x => x.MasterRating)
                .ThenByDescending(x => x.CreatedAt);
            }
            else if (reviewSort.OrderbyDescending.HasValue)
            {
                query = query.OrderByDescending(x => x.MasterRating)
                .ThenByDescending(x => x.CreatedAt);
            }
            else
            {
                query = query.OrderByDescending(x => x.CreatedAt);
            }
            return query;
        }
    }
}