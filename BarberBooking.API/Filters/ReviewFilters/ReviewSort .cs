using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Filters.ReviewFilters
{
    public class ReviewSort 
    {
        public bool? OrderBy {get; set;}
        public bool? OrderbyDescending {get; set;} 
    }
}