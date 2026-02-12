using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Filters.MasterProfile
{
    public class MasterProfileFilter
    {
        public decimal? MinRating {get; set;}
        public decimal? MaxRating {get; set;}
    }
}