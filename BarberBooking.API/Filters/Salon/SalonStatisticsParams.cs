using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Filters.Salon
{
    public class SalonStatisticsParams
    {
        public int Mounth {get; set;}
        public int Week {get; set;}
        public DateOnly Date {get; set;}
    }
}