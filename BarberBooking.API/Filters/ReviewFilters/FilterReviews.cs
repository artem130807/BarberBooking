using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Filters.ReviewFilters
{
    public class FilterReviews
    {
        public Guid? SalonId {get; set;}
        public Guid? MasterId {get; set;}
        public DateTime? From {get; set;}
        public DateTime? To {get; set;}
        public bool? LowRating {get; set;}
    }
}