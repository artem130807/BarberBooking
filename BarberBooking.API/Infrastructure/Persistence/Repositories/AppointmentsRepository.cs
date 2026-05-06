using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Enums;
using BarberBooking.API.Filters;
using BarberBooking.API.Models;
using BarberBooking.API;
using Microsoft.EntityFrameworkCore;
using BarberBooking.API.Filters.AppointmentsFilter;
using BarberBooking.API.ExtensionsProject;

namespace BarberBooking.API.Repositories
{
    public class AppointmentsRepository:IAppointmentsRepository
    {
        private readonly BarberBookingDbContext _context;
        public AppointmentsRepository(BarberBookingDbContext context)
        {
            _context = context;
        }

        public async Task<Appointments> CreateAsync(Appointments appointments)
        {
            _context.Appointments.Add(appointments);
            return appointments;
        }

        public async Task DeleteAsync(Guid Id)
        {
            await _context.Appointments
            .Where(x => x.Id == Id)
            .ExecuteDeleteAsync();
        }
        public async Task<List<Appointments>> GetByClientIdAndDate(Guid clientId, DateTime appointmentDateTime)
        {
            return await _context.Appointments
            .Include(x => x.Salon)
            .Include(x => x.Master)
                .ThenInclude(m => m.User)
            .Include(x => x.Service)
            .Where(x =>  x.ClientId == clientId && x.AppointmentDate == appointmentDateTime)
            .ToListAsync();
        }
        public async Task<Appointments> GetByMasterIdAndDate(Guid masterId, DateTime appointmentDateTime, TimeOnly startTime)
        {
            return await _context.Appointments
            .Include(x => x.Salon)
            .Include(x => x.Client)
            .Include(x => x.Service)
            .Where(x => x.MasterId == masterId 
                && x.AppointmentDate.Date == appointmentDateTime.Date
                && x.StartTime == startTime)
            .FirstOrDefaultAsync();
        }
        public async Task<Appointments> GetByIdAsync(Guid id)
        {
            return await _context.Appointments
            .Include(x => x.Salon)
            .Include(x => x.Client)
            .Include(x => x.Service)
            .Include(x => x.Master)
                .ThenInclude(m => m.User)
            .FirstOrDefaultAsync(x => x.Id == id);
        }

        public async Task<List<Appointments>> GetAppointmentsByClientId(Guid clientId)
        {
            return await _context.Appointments
            .Include(x => x.Client)
            .Include(x => x.Salon)
            .Include(x => x.Master)
                .ThenInclude(m => m.User)
            .Include(x => x.Service)
            .Where(x => x.ClientId == clientId &&
                (x.Status == AppointmentStatusEnum.Confirmed ||
                 x.Status == AppointmentStatusEnum.Completed ||
                 x.Status == AppointmentStatusEnum.Cancelled))
            .ToListAsync();
        }

        public async Task<PagedResult<Appointments>> GetAppointmentsByMasterId(Guid masterId, FilterAppointments filter ,PageParams pageParams)
        {
            return await _context.Appointments
            .Include(x => x.Salon)
            .Include(x => x.Client)
            .Include(x => x.Master)
                .ThenInclude(m => m.User)
            .Include(x => x.Service)
            .Where(x =>  x.MasterId == masterId)
            .AppointmentFilter(filter)
            .ToPagedAsync(pageParams);
        }

        public async Task<Appointments> GeAppointmentByMasterIdAndDate(Guid masterId, DateTime date)
        {
            return await _context.Appointments.FirstOrDefaultAsync(x => x.MasterId == masterId && x.AppointmentDate == date);
        }

        public async Task<PagedResult<Appointments>> GetCompletedAppointmentsByClientId(Guid clientId, PageParams pageParams)
        {        
            return await _context.Appointments
            .Include(x => x.Salon)
            .Include(x => x.Master)
                .ThenInclude(m => m.User)
            .Include(x => x.Service)
            .Where(a => a.ClientId == clientId && a.Status == AppointmentStatusEnum.Completed)
            .Where(a => !_context.Reviews.Any(r => r.AppointmentId == a.Id)).ToPagedAsync(pageParams);
        }

        public async Task<List<Appointments>> GetConfirmedAppointmentsInRange(DateTime from, DateTime to)
        {
            return await _context.Appointments
                .Include(x => x.Client)
                .Include(x => x.Salon)
                .Include(x => x.Master)
                    .ThenInclude(m => m.User)
                .Include(x => x.Service)
                .Where(x => x.Status == AppointmentStatusEnum.Confirmed
                    && x.AppointmentDate > from
                    && x.AppointmentDate <= to)
                .ToListAsync();
        }

        public async Task<PagedResult<Appointments>> GetAllAppointments(Guid salonId, FilterAppointments filter,PageParams pageParams)
        {
            return await _context.Appointments
                .AsNoTracking()
                .Include(x => x.Salon)
                .Include(x => x.Client)
                .Include(x => x.Master)
                .ThenInclude(x => x.User)
                .Include(x => x.Service)
                .Where(x => x.SalonId == salonId)
                .AppointmentFilter(filter)
                .ToPagedAsync(pageParams);
        }

        public async Task<List<Appointments>> GetAppointmentsBySalonId(Guid salonId)
        {
            return await _context.Appointments.Where(x => x.SalonId == salonId && x.Status == AppointmentStatusEnum.Completed).ToListAsync();
        }
        public async Task<int> GetCountAppointmentsBySalonId(Guid salonId)
        {
            return await _context.Appointments.Where(x => x.SalonId == salonId && x.Status == AppointmentStatusEnum.Completed).CountAsync();
        }

        public async Task<Appointments?> GetOverlappingConfirmedAppointment(
            Guid timeSlotId,
            DateTime appointmentDate,
            TimeOnly startTime,
            TimeOnly endTime)
        {
            // Npgsql: параметры для timestamptz должны быть UTC; .Date даёт Kind=Unspecified.
            var utc = appointmentDate.Kind switch
            {
                DateTimeKind.Utc => appointmentDate,
                DateTimeKind.Local => appointmentDate.ToUniversalTime(),
                _ => DateTime.SpecifyKind(appointmentDate, DateTimeKind.Utc),
            };
            var dayStart = new DateTime(utc.Year, utc.Month, utc.Day, 0, 0, 0, DateTimeKind.Utc);
            var nextDayStart = dayStart.AddDays(1);

            return await _context.Appointments
                .Where(x =>
                    x.TimeSlotId == timeSlotId &&
                    x.Status == AppointmentStatusEnum.Confirmed &&
                    x.AppointmentDate >= dayStart &&
                    x.AppointmentDate < nextDayStart &&
                    x.StartTime < endTime &&
                    startTime < x.EndTime)
                .OrderBy(x => x.StartTime)
                .FirstOrDefaultAsync();
        }

        public async Task<List<Appointments>> GetConfirmedAppointmentsCreatedSince(DateTime sinceUtc)
        {
            return await _context.Appointments
                .AsNoTracking()
                .Include(x => x.Client)
                .Include(x => x.Salon)
                .Include(x => x.Master)
                    .ThenInclude(m => m.User)
                .Include(x => x.Service)
                .Where(x => x.Status == AppointmentStatusEnum.Confirmed
                    && x.CreatedAt >= sinceUtc)
                .ToListAsync();
        }

        public async Task StatusUpdateRange(Guid timeSlotId, AppointmentStatusEnum status)
        {
           await _context.Appointments.Where(x => x.TimeSlotId == timeSlotId 
           && x.Status == AppointmentStatusEnum.Confirmed)
           .ExecuteUpdateAsync(s => 
           s.SetProperty(s => s.Status, status));
        }

        public async Task<PagedResult<Appointments>> GetPagedAppointmentsByTimeSlotId(Guid timeSlotId, PageParams pageParams, StatusFilter filter)
        {
            var query = _context.Appointments
            .Include(x => x.Client)
            .Include(x => x.Service)
            .Include(x => x.Master)
                .ThenInclude(m => m.User)
            .Include(x => x.TimeSlot)
            .Where(x => x.TimeSlotId == timeSlotId);
            var anyStatus = filter.Confirmed == true || filter.Completed == true ||
                            filter.Cancelled == true;
            if (anyStatus)
            {
                query = query.Where(x =>
                    (filter.Confirmed == true && x.Status == AppointmentStatusEnum.Confirmed) ||
                    (filter.Completed == true && x.Status == AppointmentStatusEnum.Completed) ||
                    (filter.Cancelled == true && x.Status == AppointmentStatusEnum.Cancelled));
            }

            return await query.ToPagedAsync(pageParams);
        }

        public async Task<List<Appointments>> GetAppointmentsByTimeSlotId(Guid timeSlotId)
        {
            return await _context.Appointments
            .Include(x => x.Client)
            .Include(x => x.Service)
            .Include(x => x.Master)
                .ThenInclude(m => m.User)
            .Include(x => x.TimeSlot)
            .Where(x => x.TimeSlotId == timeSlotId).ToListAsync();
        }

        public async Task<List<Appointments>> GetAppointmentsByDateTo(DateTime appointmentDateTo)
        {
            return await _context.Appointments.Where(x => x.AppointmentDate.Date < appointmentDateTo.Date && x.Status == AppointmentStatusEnum.Confirmed).ToListAsync();
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
    }
}
