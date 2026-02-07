using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Enums;

namespace BarberBooking.API.Dto.DtoMasterTimeSlot
{
    public class DtoUpdateMasterTimeSlot
    {
        public DateOnly? ScheduleDate { get;  set; }
        public TimeOnly? StartTime { get; set; } 
        public TimeOnly? EndTime { get; set; } 
        public MasterTimeSlotStatus? Status {get; set;}
    }
}