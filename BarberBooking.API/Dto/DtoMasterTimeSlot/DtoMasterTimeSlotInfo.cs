using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoMasterTimeSlot
{
    public class DtoMasterTimeSlotInfo
    {
        public Guid Id {get; private set;}
        public DateOnly ScheduleDate { get; set; }
        public TimeOnly StartTime { get; set; } 
        public TimeOnly EndTime { get; set; } 
    }
}