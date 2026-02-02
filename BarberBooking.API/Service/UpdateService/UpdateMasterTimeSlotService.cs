
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using BarberBooking.API.Models;

namespace BarberBooking.API.Service.UpdateService
{
    public class UpdateMasterTimeSlotService : IUpdateMasterTimeSlotService
    {
        public async Task UpdateAsync(MasterTimeSlot timeSlot, DtoUpdateMasterTimeSlot? dto)
        {
            var scheduleDate = dto.ScheduleDate.HasValue ? dto.ScheduleDate : timeSlot.ScheduleDate;
            timeSlot.UpdateScheduleDate(scheduleDate.Value);
            var startTime = dto.StartTime.HasValue ? dto.StartTime : timeSlot.StartTime;
            timeSlot.UpdateStartTime(startTime.Value);
            var endTime = dto.EndTime.HasValue ? dto.EndTime : timeSlot.EndTime;
            timeSlot.UpdateEndTime(endTime.Value);
            var status = dto.Status.HasValue ? dto.Status : timeSlot.Status;
            timeSlot.UpdateMasterTimeSlotStatus(status.Value);
        }
    }


}