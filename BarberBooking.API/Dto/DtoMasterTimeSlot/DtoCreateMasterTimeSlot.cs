using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoMasterTimeSlot
{
    public class DtoCreateMasterTimeSlot
    {
        public Guid MasterId { get; set; }
        public DateOnly ScheduleDate { get; set; } 
        public TimeOnly StartTime { get; set; } 
        public TimeOnly EndTime { get; set; } 
    }
}