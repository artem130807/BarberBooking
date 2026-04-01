using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Enums;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Models
{
    public class MasterTimeSlot
    {
        public Guid Id { get; private set; } 
        public Guid MasterId { get; private set; }
        public DateOnly ScheduleDate { get; private set; }
        public TimeOnly StartTime { get; private set; } 
        public TimeOnly EndTime { get; private set; } 
        public MasterTimeSlotStatus Status {get; private set;}
        public MasterProfile Master {get; private set;}
        public ICollection<Appointments> Appointments { get; private set; }
        private MasterTimeSlot()
        {
            Appointments = new List<Appointments>();
        }
        public static MasterTimeSlot Create(Guid masterId, DateOnly scheduleDate, TimeOnly startTime, TimeOnly endTime)
        {
            var timeSlot = new MasterTimeSlot
            {
                Id = Guid.NewGuid(),
                MasterId = masterId,
                ScheduleDate = scheduleDate,
                StartTime = startTime,
                EndTime = endTime,
            };
            return timeSlot;
        }
        public static MasterTimeSlot CreatePreview(Guid sourceSlotId, Guid masterId, DateOnly scheduleDate, TimeOnly startTime, TimeOnly endTime)
        {
            var timeSlot = new MasterTimeSlot
            {
                Id = sourceSlotId,
                MasterId = masterId,
                ScheduleDate = scheduleDate,
                StartTime = startTime,
                EndTime = endTime,
            };
            return timeSlot;
        }
        public void UpdateScheduleDate(DateOnly scheduleDate) => ScheduleDate = scheduleDate;
        public void UpdateStartTime(TimeOnly startTime) => StartTime = startTime;
        public void UpdateEndTime(TimeOnly endTime) => EndTime = endTime;
        public void UpdateMasterTimeSlotStatus(MasterTimeSlotStatus status) => Status = status;
    }
}