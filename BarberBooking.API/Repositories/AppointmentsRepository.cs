using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

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
        public async Task<List<Appointments>> GetByMasterIdAndDate(Guid masterId, DateTime appointmentDateTime)
        {
            return await _context.Appointments
            .Include(x => x.Salon)
            .Include(x => x.Client)
            .Include(x => x.Service)
            .Where(x =>  x.MasterId == masterId && x.AppointmentDate == appointmentDateTime)
            .ToListAsync();
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
            .Include(x => x.Salon)
            .Include(x => x.Master)
            .Include(x => x.Service)
            .Where(x =>  x.ClientId == clientId)
            .ToListAsync();
        }

        public async Task<List<Appointments>> GetAppointmentsByMasterId(Guid masterId)
        {
            return await _context.Appointments
            .Include(x => x.Salon)
            .Include(x => x.Master)
            .Include(x => x.Service)
            .Where(x =>  x.MasterId == masterId)
            .ToListAsync();
        }
    }
}