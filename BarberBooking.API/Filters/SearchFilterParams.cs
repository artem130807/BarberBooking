using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Filters
{
    public class SearchFilterParams
    {
        public string? SalonName {get; set;}
        public string? City {get; set;}
    }
}