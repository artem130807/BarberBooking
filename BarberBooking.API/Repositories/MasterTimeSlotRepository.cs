using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Repositories
{
    public class MasterTimeSlotRepository : IMasterTimeSlotRepository
    {
        private static readonly TimeSpan SlotStep = TimeSpan.FromMinutes(15);

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
                .OrderBy(x => x.StartTime)
                .ToListAsync();

            if (slots.Count == 0)
                return new List<MasterTimeSlot>();

            var today = DateOnly.FromDateTime(DateTime.Now);
            var currentTime = TimeOnly.FromDateTime(DateTime.Now);
            var freeSegments = new List<(TimeOnly Start, TimeOnly End)>();

            foreach (var slot in slots)
            {
                TimeOnly segmentStart = slot.StartTime;
                TimeOnly segmentEnd = slot.EndTime;

                if (date == today && segmentStart < currentTime)
                {
                    segmentStart = currentTime;
                    if (segmentEnd <= segmentStart || (segmentEnd - segmentStart) < serviceDuration)
                        continue;
                }

                var appointmentsOnDate = slot.Appointments
                    .Where(a => DateOnly.FromDateTime(a.AppointmentDate) == date)
                    .OrderBy(a => a.StartTime)
                    .ToList();

                if (appointmentsOnDate.Count == 0)
                {
                    freeSegments.Add((segmentStart, segmentEnd));
                    continue;
                }

                var previousEnd = segmentStart;
                foreach (var appointment in appointmentsOnDate)
                {
                    if (appointment.StartTime <= segmentStart)
                    {
                        previousEnd = previousEnd > appointment.EndTime ? previousEnd : appointment.EndTime;
                        continue;
                    }
                    var freeEnd = appointment.StartTime;
                    if ((freeEnd - previousEnd) >= serviceDuration)
                        freeSegments.Add((previousEnd, freeEnd));
                    previousEnd = previousEnd > appointment.EndTime ? previousEnd : appointment.EndTime;
                }

                if ((segmentEnd - previousEnd) >= serviceDuration)
                    freeSegments.Add((previousEnd, segmentEnd));
            }

            var availableSlots = new List<MasterTimeSlot>();
            foreach (var (start, end) in freeSegments)
            {
                var effectiveStart = RoundUpToStep(start);
                if (effectiveStart >= end)
                    continue;
                for (var t = effectiveStart; t.Add(serviceDuration) <= end; t = t.Add(SlotStep))
                {
                    var slotEnd = t.Add(serviceDuration);
                    availableSlots.Add(MasterTimeSlot.Create(masterId, date, t, slotEnd));
                }
            }

            return availableSlots.OrderBy(s => s.StartTime).ToList();
        }

        private static TimeOnly RoundUpToStep(TimeOnly time)
        {
            var stepMinutes = (int)SlotStep.TotalMinutes;
            var totalMinutes = time.Hour * 60 + time.Minute;
            var rounded = ((totalMinutes + stepMinutes - 1) / stepMinutes) * stepMinutes;
            if (rounded >= 24 * 60)
                rounded = 24 * 60 - stepMinutes;
            return new TimeOnly(rounded / 60, rounded % 60);
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