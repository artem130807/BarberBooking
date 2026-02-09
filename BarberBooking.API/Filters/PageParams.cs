using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;

namespace BarberBooking.API.Filters
{
    public class PageParams
    {
        public int? Page { get; set; }
        public int? PageSize { get; set; }
    }
}