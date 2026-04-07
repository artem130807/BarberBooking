using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Filters.AppointmentsFilter
{
    public class StatusFilter
    {
        public bool? Confirmed {get; set;}
        public bool? Completed {get; set;}
        public bool? Cancelled {get; set;}
    }
}