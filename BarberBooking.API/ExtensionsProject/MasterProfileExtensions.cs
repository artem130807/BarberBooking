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
            if(masterProfile.MinRating.HasValue)
                query = query.Where(x => x.Rating >= masterProfile.MinRating);
            if(masterProfile.MaxRating.HasValue)
                query = query.Where(x => x.Rating >= masterProfile.MaxRating);
            return query;
        }
    }
}