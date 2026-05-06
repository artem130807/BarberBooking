using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
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
        private static readonly TimeSpan SalonCardAvailabilityServiceDuration = TimeSpan.FromMinutes(40);

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

            var today = DateOnly.FromDateTime(DateTime.UtcNow);
            var currentTime = RoundUpToMinute(TimeOnly.FromDateTime(DateTime.UtcNow));
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
                    .Where(a =>
                        DateOnly.FromDateTime(a.AppointmentDate) == date
                        && a.Status != AppointmentStatusEnum.Cancelled)
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
                AddPreviewSlotsInRange(availableSlots, sourceSlotId, masterId, date, start, end, serviceDuration);
            }

            return availableSlots.OrderBy(s => s.StartTime).ToList();
        }

        private static List<(Guid SourceSlotId, TimeOnly Start, TimeOnly End)> BuildFreeSegments(
            IReadOnlyList<MasterTimeSlot> slots,
            DateOnly date,
            TimeSpan serviceDuration)
        {
            var today = DateOnly.FromDateTime(DateTime.UtcNow);
            var currentTime = RoundUpToMinute(TimeOnly.FromDateTime(DateTime.UtcNow));
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
                    .Where(a =>
                        DateOnly.FromDateTime(a.AppointmentDate) == date
                        && a.Status != AppointmentStatusEnum.Cancelled)
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

            return freeSegments;
        }
        private static int CountPreviewSlotsInRange(TimeOnly start, TimeOnly end, TimeSpan serviceDuration)
        {
            var startMinutes = start.ToTimeSpan().TotalMinutes;
            var endMinutes = end.ToTimeSpan().TotalMinutes;
            var stepMinutes = serviceDuration.TotalMinutes;

            if (stepMinutes <= 0 || startMinutes > endMinutes)
                return 0;

            const int maxPreviewSlots = 4096;
            var generated = 0;
            var count = 0;

            for (var t = startMinutes; t + stepMinutes <= endMinutes; t += stepMinutes)
            {
                if (++generated > maxPreviewSlots)
                    break;
                count++;
            }

            return count;
        }

        private static void AddPreviewSlotsInRange(
            List<MasterTimeSlot> availableSlots,
            Guid sourceSlotId,
            Guid masterId,
            DateOnly date,
            TimeOnly start,
            TimeOnly end,
            TimeSpan serviceDuration)
        {
            var startMinutes = start.ToTimeSpan().TotalMinutes;
            var endMinutes = end.ToTimeSpan().TotalMinutes;
            var stepMinutes = serviceDuration.TotalMinutes;

            if (stepMinutes <= 0 || startMinutes > endMinutes)
                return;

            const int maxPreviewSlots = 4096;
            var generated = 0;

            for (var t = startMinutes; t + stepMinutes <= endMinutes; t += stepMinutes)
            {
                if (++generated > maxPreviewSlots)
                {
                    break;
                }

                var tStart = TimeOnly.FromTimeSpan(TimeSpan.FromMinutes(t));
                var tEnd = TimeOnly.FromTimeSpan(TimeSpan.FromMinutes(t + stepMinutes));
                availableSlots.Add(MasterTimeSlot.CreatePreview(sourceSlotId, masterId, date, tStart, tEnd));
            }
        }

        private static TimeOnly RoundUpToMinute(TimeOnly time)
        {
            var rounded = new TimeOnly(time.Hour, time.Minute);
            if (time.Second > 0 || time.Millisecond > 0)
                rounded = rounded.AddMinutes(1);
            return rounded;
        }

        public async Task<int> GetAvailableSlotsInSalon(Guid salonId, DateOnly date)
        {
            var map = await GetAvailableSlotsCountBySalonIdsAsync(
                new[] { salonId },
                date,
                CancellationToken.None);
            return map.TryGetValue(salonId, out var n) ? n : 0;
        }

        public async Task<IReadOnlyDictionary<Guid, int>> GetAvailableSlotsCountBySalonIdsAsync(
            IReadOnlyList<Guid> salonIds,
            DateOnly date,
            CancellationToken cancellationToken = default)
        {
            if (salonIds == null || salonIds.Count == 0)
                return new Dictionary<Guid, int>();

            var distinctIds = salonIds.Distinct().ToList();
            var result = distinctIds.ToDictionary(id => id, _ => 0);

            var allSlots = await _context.MasterTimeSlots
                .AsNoTracking()
                .AsSplitQuery()
                .Include(x => x.Appointments)
                .Include(x => x.Master)
                .Where(x => x.ScheduleDate == date && distinctIds.Contains(x.Master!.SalonId))
                .OrderBy(x => x.Master!.SalonId)
                .ThenBy(x => x.MasterId)
                .ThenBy(x => x.StartTime)
                .ToListAsync(cancellationToken);

            if (allSlots.Count == 0)
                return result;

            var duration = SalonCardAvailabilityServiceDuration;

            foreach (var salonGroup in allSlots.GroupBy(x => x.Master!.SalonId))
            {
                var sum = 0;
                foreach (var masterGroup in salonGroup.GroupBy(x => x.MasterId))
                {
                    var slots = masterGroup.ToList();
                    var freeSegments = BuildFreeSegments(slots, date, duration);
                    foreach (var segment in freeSegments)
                    {
                        sum += CountPreviewSlotsInRange(segment.Start, segment.End, duration);
                    }
                }

                result[salonGroup.Key] = sum;
            }

            return result;
        }

        public async Task<MasterTimeSlot?> GetByIdAsync(Guid id)
        {
            return await _context.MasterTimeSlots
            .Include(x => x.Master)
            .Include(x => x.Appointments)
            .FirstOrDefaultAsync(x => x.Id == id);
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
        public async Task<MasterTimeSlot> ForUpdate(Guid timeSlotId)
        {
            return await _context.MasterTimeSlots
                .FromSqlInterpolated(
                    $"""SELECT * FROM "MasterTimeSlots" AS m WHERE m."Id" = {timeSlotId} FOR UPDATE""")
                .AsTracking()
                .FirstAsync();
        }
    }
}