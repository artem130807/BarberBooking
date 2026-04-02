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
            .FirstOrDefaultAsync(x => x.Id == id);
        }

        public async Task<List<Appointments>> GetAppointmentsByClientId(Guid clientId)
        {
            return await _context.Appointments
            .Include(x => x.Client)
            .Include(x => x.Salon)
            .Include(x => x.Master)
            .Include(x => x.Service)
            .Where(x =>  x.ClientId == clientId && x.Status == AppointmentStatusEnum.Confirmed)
            .ToListAsync();
        }

        public async Task<PagedResult<Appointments>> GetAppointmentsByMasterId(Guid masterId, FilterAppointments filter ,PageParams pageParams)
        {
            return await _context.Appointments
            .Include(x => x.Salon)
            .Include(x => x.Client)
            .Include(x => x.Master)
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
            return await _context.Appointments.Include(x => x.Salon).Include(x => x.Master).Include(x => x.Service)
            .Where(a => a.ClientId == clientId && a.Status == AppointmentStatusEnum.Completed)
            .Where(a => !_context.Reviews.Any(r => r.AppointmentId == a.Id)).ToPagedAsync(pageParams);
        }

        public async Task<List<Appointments>> GetConfirmedAppointmentsInRange(DateTime from, DateTime to)
        {
            return await _context.Appointments
                .Include(x => x.Client)
                .Include(x => x.Salon)
                .Include(x => x.Master)
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

        public async Task<Appointments> GetAppointmentActive(Guid timeSlotId)
        {
            return await _context.Appointments.FirstOrDefaultAsync(x => x.TimeSlotId == timeSlotId && x.Status == AppointmentStatusEnum.Confirmed);
        }

        public async Task<List<Appointments>> GetConfirmedAppointmentsCreatedSince(DateTime sinceUtc)
        {
            return await _context.Appointments
                .AsNoTracking()
                .Include(x => x.Client)
                .Include(x => x.Salon)
                .Include(x => x.Master)
                .Include(x => x.Service)
                .Where(x => x.Status == AppointmentStatusEnum.Confirmed
                    && x.CreatedAt >= sinceUtc)
                .ToListAsync();
        }

        public async Task StatusUpdateRange(Guid timeSlotId, AppointmentStatusEnum status)
        {
           await _context.Appointments.Where(x => x.TimeSlotId == timeSlotId)
           .ExecuteUpdateAsync(s => 
           s.SetProperty(s => s.Status, status));
        }

        public async Task<List<Appointments>> GetAppointmentsByTimeSlotId(Guid timeSlotId)
        {
            return await _context.Appointments.Where(x => x.TimeSlotId == timeSlotId).ToListAsync();
        }
    }
}
