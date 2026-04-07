using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Enums;
using BarberBooking.API.Models;

namespace BarberBooking.API.Dto.DtoMasterTimeSlot
{
    public class DtoMasterTimeSlotInfo
    {
        public Guid Id {get; set;}
        public Guid MasterId {get; set;}
        public DateOnly ScheduleDate { get; set; }
        public TimeOnly StartTime { get; set; } 
        public TimeOnly EndTime { get; set; } 
        public MasterTimeSlotStatus Status {get; set;}
        public int TimeSlotCount {get; set;}
    }
}