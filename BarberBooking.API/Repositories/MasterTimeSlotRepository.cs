using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Enums;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Repositories
{
    public class MasterTimeSlotRepository : IMasterTimeSlotRepository
    {
        private static readonly TimeSpan MinLeadTime = TimeSpan.FromMinutes(15);

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
            if (serviceDuration <= TimeSpan.Zero)
                return new List<MasterTimeSlot>();

            var slots = await _context.MasterTimeSlots
                .Include(x => x.Appointments)
                .Where(x => x.MasterId == masterId && x.ScheduleDate == date)
                .OrderBy(x => x.StartTime)
                .ToListAsync();

            if (slots.Count == 0)
                return new List<MasterTimeSlot>();

            var today = DateOnly.FromDateTime(DateTime.Now);
            var currentTime = RoundUpToMinute(TimeOnly.FromDateTime(DateTime.Now));
            var earliestStartToday = currentTime.Add(MinLeadTime);
            var freeSegments = new List<(Guid SourceSlotId, TimeOnly Start, TimeOnly End)>();

            foreach (var slot in slots)
            {
                TimeOnly segmentStart = slot.StartTime;
                TimeOnly segmentEnd = slot.EndTime;

                if (date == today && segmentStart < earliestStartToday)
                {
                    segmentStart = earliestStartToday;
                    if (segmentEnd <= segmentStart || (segmentEnd - segmentStart) < serviceDuration)
                        continue;
                }

                var appointmentsOnDate = slot.Appointments
                    .Where(a => DateOnly.FromDateTime(a.AppointmentDate) == date)
                    .OrderBy(a => a.StartTime)
                    .ToList();

                if (appointmentsOnDate.Count == 0)
                {
                    freeSegments.Add((slot.Id, segmentStart, segmentEnd));
                    continue;
                }

                var previousEnd = segmentStart;
                foreach (var appointment in appointmentsOnDate)
                {
                    var busyStart = appointment.StartTime < segmentStart ? segmentStart : appointment.StartTime;
                    var busyEnd = appointment.EndTime > segmentEnd ? segmentEnd : appointment.EndTime;

                    if (busyEnd <= previousEnd)
                        continue;

                    if (busyStart <= previousEnd)
                    {
                        previousEnd = busyEnd;
                        continue;
                    }

                    var freeEnd = busyStart;
                    if ((freeEnd - previousEnd) >= serviceDuration)
                        freeSegments.Add((slot.Id, previousEnd, freeEnd));

                    previousEnd = busyEnd;
                }

                if ((segmentEnd - previousEnd) >= serviceDuration)
                    freeSegments.Add((slot.Id, previousEnd, segmentEnd));
            }

            var availableSlots = new List<MasterTimeSlot>();
            foreach (var (sourceSlotId, start, end) in freeSegments)
            {
                for (var t = start; t.Add(serviceDuration) <= end; t = t.Add(serviceDuration))
                {
                    var slotEnd = t.Add(serviceDuration);
                    availableSlots.Add(MasterTimeSlot.CreatePreview(sourceSlotId, masterId, date, t, slotEnd));
                }
            }

            return availableSlots.OrderBy(s => s.StartTime).ToList();
        }

        private static TimeOnly RoundUpToMinute(TimeOnly time)
        {
            var rounded = new TimeOnly(time.Hour, time.Minute);
            if (time.Second > 0 || time.Millisecond > 0)
                rounded = rounded.AddMinutes(1);
            return rounded;
        }

        public async Task<List<MasterTimeSlot>> GetAvailableSlotsInSalons(DateOnly date)
        {
            var today = DateOnly.FromDateTime(DateTime.Now);
            var currentTime = RoundUpToMinute(TimeOnly.FromDateTime(DateTime.Now));
            var earliestStartToday = currentTime.Add(MinLeadTime);

            var query = _context.MasterTimeSlots
                .Include(x => x.Master)
                .Where(x => x.ScheduleDate == date)
                .Where(x => x.Status == MasterTimeSlotStatus.Available);

            if (date == today)
            {
                query = query.Where(x => x.EndTime > earliestStartToday);
            }

            return await query
                .OrderBy(x => x.MasterId)
                .ThenBy(x => x.StartTime)
                .ToListAsync();
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