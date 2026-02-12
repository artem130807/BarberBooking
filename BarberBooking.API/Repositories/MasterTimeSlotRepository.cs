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
        private readonly BarberBookingDbContext _context;
        private readonly ILogger<MasterTimeSlotRepository> _logger;
        public MasterTimeSlotRepository(BarberBookingDbContext context, ILogger<MasterTimeSlotRepository> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task<MasterTimeSlot> CreateAsync(MasterTimeSlot timeSlot)
        {
            _context.Add(timeSlot);
            return timeSlot;
        }

        public async Task<List<MasterTimeSlot>> CreateRangeAsync(List<MasterTimeSlot> timeSlots)
        {
            await _context.AddRangeAsync(timeSlots);
            return timeSlots;
        }

        public async Task DeleteAsync(Guid timeSlotId)
        {
            await _context.MasterTimeSlots
            .Where(x => x.Id == timeSlotId)
            .ExecuteDeleteAsync();
        }

        public async Task<MasterTimeSlot?> FindSlotAsync(Guid masterId, DateOnly date, TimeOnly startTime)
        {
            return await _context.MasterTimeSlots
            .FirstOrDefaultAsync(x => x.MasterId == masterId && x.ScheduleDate == date && x.StartTime == startTime);
        }

        public async Task<List<MasterTimeSlot>> GetAvailableSlotsAsync(Guid masterId, DateOnly date, TimeSpan serviceDuration)
        {
            var slots = await _context.MasterTimeSlots
                .Include(x => x.Appointments)
                .Where(x => x.MasterId == masterId && x.ScheduleDate == date)
                .ToListAsync();

            if (!slots.Any())
                return new List<MasterTimeSlot>();

            var availableSlots = new List<MasterTimeSlot>();
            var currentTime = TimeOnly.FromDateTime(DateTime.Now);
            var today = DateOnly.FromDateTime(DateTime.Now);

            foreach (var slot in slots)
            {
                TimeOnly slotStart = slot.StartTime;
                TimeOnly slotEnd = slot.EndTime;

                if (date == today && slotStart < currentTime)
                {
                    slotStart = currentTime;
                    if (slotEnd - slotStart < serviceDuration)
                        continue;
                }

                var appointments = slot.Appointments
                    .Where(a => DateOnly.FromDateTime(a.AppointmentDate) == date)
                    .OrderBy(a => a.StartTime)
                    .ToList();

                if (!appointments.Any())
                {
                    var endTime = slotStart.Add(serviceDuration);
                    if (endTime <= slotEnd)
                    {
                        availableSlots.Add(MasterTimeSlot.Create(
                            slot.MasterId, date, slotStart, endTime));
                    }
                    continue;
                }

                var previousEnd = slotStart;
                foreach (var appointment in appointments)
                {
                    if (appointment.StartTime < slotStart)
                        continue;

                    var freeTime = appointment.StartTime - previousEnd;
                    if (freeTime >= serviceDuration)
                    {
                        var endTime = previousEnd.Add(serviceDuration);
                        availableSlots.Add(MasterTimeSlot.Create(
                            slot.MasterId, date, previousEnd, endTime));
                    }
                    previousEnd = appointment.EndTime > previousEnd ? 
                        appointment.EndTime : previousEnd;
                }

                if (slotEnd - previousEnd >= serviceDuration)
                {
                    var endTime = previousEnd.Add(serviceDuration);
                    availableSlots.Add(MasterTimeSlot.Create(
                        slot.MasterId, date, previousEnd, endTime));
                }
            }

            return availableSlots;
        }

        public async Task<List<MasterTimeSlot>> GetAvailableSlotsInSalons(DateOnly date)
        {
            var slots = await _context.MasterTimeSlots
            .Include(x => x.Appointments)
            .Where (x => x.ScheduleDate == date)
            .ToListAsync();
            var availableSlots = new List<MasterTimeSlot>();
            foreach(var slot in slots)
            {
                var appointments = await _context.Appointments.Where(x => x.TimeSlotId == slot.Id).ToListAsync();
                if(appointments == null)
                {
                    availableSlots.Add(slot);
                }
            }
            return availableSlots;
        }

        public async Task<MasterTimeSlot?> GetByIdAsync(Guid id)
        {
            return await _context.MasterTimeSlots.FindAsync(id);
        }

        public async Task<List<MasterTimeSlot>> GetByMasterAsync(Guid masterId, DateOnly date)
        {
            return await _context.MasterTimeSlots.Where(x => x.MasterId == masterId && x.ScheduleDate == date).ToListAsync();
        }

        public async Task<List<MasterTimeSlot>> GetTimeSlotsInSalon(Guid salonId, DateOnly date)
        {
            return await _context.MasterTimeSlots
            .Include(x => x.Master)
            .ThenInclude(x => x.Salon)
            .Where(x => x.Master.Salon.Id == salonId && x.ScheduleDate == date)
            .ToListAsync();
        }
    }
}