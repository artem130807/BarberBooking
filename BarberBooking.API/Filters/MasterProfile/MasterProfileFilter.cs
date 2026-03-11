using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Filters.MasterProfile
{
    public class MasterProfileFilter
    {
        public bool? MaxRating {get; set;}
        public bool? Popular {get; set;}
    }
}