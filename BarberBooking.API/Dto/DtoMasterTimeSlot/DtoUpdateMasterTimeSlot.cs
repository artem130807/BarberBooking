using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Enums;

namespace BarberBooking.API.Dto.DtoMasterTimeSlot
{
    public class DtoUpdateMasterTimeSlot
    {
        public DateTime? ScheduleDate { get;  set; }
        public TimeSpan? StartTime { get; set; } 
        public TimeSpan? EndTime { get; set; } 
        public MasterTimeSlotStatus? Status {get; set;}
    }
}