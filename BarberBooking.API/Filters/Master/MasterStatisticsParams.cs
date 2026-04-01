using System;

namespace BarberBooking.API.Filters.Master
{
    public class MasterStatisticsParams
    {
        public int Mounth { get; set; }
        public int Week { get; set; }
        public DateOnly Date { get; set; }
    }
}
