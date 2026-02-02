using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Models;
using Microsoft.AspNetCore.Routing.Constraints;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Repositories
{
    public class MasterTimeSlotRepository:IMasterTimeSlotRepository
    {
        private readonly BarberBookingDbContext _dbContext;
        public MasterTimeSlotRepository(BarberBookingDbContext dbContext)
        {
          _dbContext = dbContext;
        }

        public async Task<MasterTimeSlot> CreateAsync(MasterTimeSlot timeSlot)
        {
            _dbContext.Add(timeSlot);
            return timeSlot;
        }

        public async Task<List<MasterTimeSlot>> CreateRangeAsync(List<MasterTimeSlot> timeSlots)
        {
            await _dbContext.AddRangeAsync(timeSlots);
            return timeSlots;
        }

        public async Task<MasterTimeSlot> DeleteAsync(Guid timeSlotId)
        {
            var timeSlot = await _dbContext.MasterTimeSlots.FindAsync(timeSlotId);
            await _dbContext.MasterTimeSlots
            .Where(x => x.Id == timeSlotId)
            .ExecuteDeleteAsync();
            return timeSlot;
        }

        public async Task<MasterTimeSlot?> FindSlotAsync(Guid masterId, DateTime date, TimeSpan startTime)
        {
            return await _dbContext.MasterTimeSlots
            .FirstOrDefaultAsync(x => x.MasterId == masterId && x.ScheduleDate == date && x.StartTime == startTime);
        }

        public async Task<List<MasterTimeSlot>> GetAvailableSlotsAsync(Guid masterId, DateTime date, TimeSpan serviceDuration)
        {
            var slots = await _dbContext.MasterTimeSlots.Include(x => x.Appointments).Where(x => x.MasterId == masterId && x.ScheduleDate == date).ToListAsync();
            var availableSlots = new List<MasterTimeSlot>();
            foreach(var slot in slots)
            {
                if (date.Date == DateTime.Today && slot.StartTime < DateTime.Now.TimeOfDay)
                    continue;
                var hoursSlot = slot.EndTime - slot.StartTime;
                if (hoursSlot < serviceDuration)
                    continue;
                
                var appointments = slot.Appointments.Where(a => a.AppointmentDate.Date == date.Date) 
                .OrderBy(a => a.StartTime)
                .ToList();
                if (!appointments.Any())
                {
                    availableSlots.Add(slot);
                    continue;
                }
                var previousEnd = slot.StartTime;
                
                foreach(var appointment in appointments)
                {
                    var freeTime = appointment.StartTime - previousEnd;
                    if (freeTime >= serviceDuration)
                    {
                        var endTime = previousEnd + serviceDuration;
                        availableSlots.Add(MasterTimeSlot.Create(slot.MasterId, slot.ScheduleDate, previousEnd, endTime));
                    }
                    previousEnd = appointment.EndTime;
                }
                
                if (slot.EndTime - previousEnd >= serviceDuration)
                {
                    var endTime = previousEnd + serviceDuration;
                    availableSlots.Add(MasterTimeSlot.Create(slot.MasterId, slot.ScheduleDate, previousEnd, endTime));
                }
            }
            return availableSlots;
        }


        public async Task<MasterTimeSlot?> GetByIdAsync(Guid id)
        {
            return await _dbContext.MasterTimeSlots.FindAsync(id);
        }

        public async Task<List<MasterTimeSlot>> GetByMasterAsync(Guid masterId, DateTime date)
        {
            return await _dbContext.MasterTimeSlots.Where(x => x.MasterId == masterId && x.ScheduleDate == date).ToListAsync();
        }

    }
}