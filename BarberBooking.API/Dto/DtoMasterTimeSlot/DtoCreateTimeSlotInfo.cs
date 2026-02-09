using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoMasterTimeSlot
{
    public class DtoCreateTimeSlotInfo
    {
        public Guid Id {get; private set;}
        public Guid MasterId {get; private set;}
        public DateOnly ScheduleDate { get; private set; }
        public TimeOnly StartTime { get; private set; } 
        public TimeOnly EndTime { get; private set; } 
    }
}