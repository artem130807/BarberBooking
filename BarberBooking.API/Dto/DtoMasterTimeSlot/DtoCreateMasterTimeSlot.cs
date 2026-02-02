using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoMasterTimeSlot
{
    public class DtoCreateMasterTimeSlot
    {
        public Guid MasterId { get; set; }
        public DateTime ScheduleDate { get; set; } 
        public TimeSpan StartTime { get; set; } 
        public TimeSpan EndTime { get; set; } 
    }
}