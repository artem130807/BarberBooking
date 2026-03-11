using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Filters.MasterProfile;
using BarberBooking.API.Models;

namespace BarberBooking.API.ExtensionsProject
{
    public static class MasterProfileExtensions
    {
        public static IQueryable<MasterProfile> FilterMasterProfile(this IQueryable<MasterProfile> query, MasterProfileFilter masterProfile)
        {
            if(masterProfile.MaxRating.HasValue)
                query = query.OrderByDescending(x => x.Rating);
            if(masterProfile.Popular.HasValue)
                query = query.OrderByDescending(x => x.RatingCount);
            return query;
        }
    }
}