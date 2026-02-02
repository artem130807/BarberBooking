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
        public DateTime  ScheduleDate { get; private set; }
        public TimeSpan StartTime { get; private set; } 
        public TimeSpan EndTime { get; private set; } 
        public MasterTimeSlotStatus Status {get; private set;}
        public MasterProfile Master {get; private set;}
        public ICollection<Appointments> Appointments { get; private set; }
        private MasterTimeSlot()
        {
            Appointments = new List<Appointments>();
        }
        public static MasterTimeSlot Create(Guid masterId, DateTime scheduleDate, TimeSpan startTime, TimeSpan endTime)
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
        public void UpdateScheduleDate(DateTime scheduleDate) => ScheduleDate = scheduleDate;
        public void UpdateStartTime(TimeSpan startTime) => StartTime = startTime;
        public void UpdateEndTime(TimeSpan endTime) => EndTime = endTime;
        public void UpdateMasterTimeSlotStatus(MasterTimeSlotStatus status) => Status = status;
    }
}