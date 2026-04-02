using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Filters.AppointmentsFilter
{
    public class FilterAppointments
    {
        public bool? Confirmed {get; set;}
        public bool? Completed {get; set;}
        public bool? Cancelled {get; set;}
        public bool? ThisMounth {get; set;}
        public bool? ThisWeek {get; set;}
        public bool? ThisDay {get; set;}
        public DateTime? from {get; set;}
        public DateTime? to {get; set;}
        public DateTime? AppointmentFrom { get; set; }
        public DateTime? AppointmentTo { get; set; }
    }
}