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
        private readonly BarberBookingDbContext _dbContext;
        public AppointmentsRepository(BarberBookingDbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<Appointments> CreateAsync(Appointments appointments)
        {
            _dbContext.Appointments.Add(appointments);
            return appointments;
        }

        public async Task DeleteAsync(Guid Id)
        {
            await _dbContext.Appointments
            .Where(x => x.Id == Id)
            .ExecuteDeleteAsync();
        }

        public async Task<Appointments> GetByIdAndUserIdAsync(Guid Id, Guid ClientId)
        {
            return await _dbContext.Appointments.FirstOrDefaultAsync(x => x.Id == Id && x.ClientId == ClientId);
        }

        public async Task<Appointments> GetByClientIdAndDateAsync(DateTime appointmentDateTime, Guid clientId)
        {
            return await _dbContext.Appointments.FirstOrDefaultAsync(x => x.AppointmentDate == appointmentDateTime && x.ClientId == clientId);
        }

        public async Task<List<Appointments>> GetAppointmentsAsync()
        {
            return await _dbContext.Appointments.ToListAsync();
        }
        public async Task<Appointments?> GetByMasterAndDateTimeAsync(Guid masterId, DateTime appointmentDateTime)
        {
            return await _dbContext.Appointments.FirstOrDefaultAsync(x =>  x.MasterId == masterId && x.AppointmentDate == appointmentDateTime);
        }

        public async Task<Appointments?> GetByIdAsync(Guid id)
        {
            return await _dbContext.Appointments.FindAsync(id);
        }

        public async Task<List<Appointments>> GetByMasterTodayAsync(Guid masterId)
        {
            return await _dbContext.Appointments.Where(x => x.MasterId == masterId).ToListAsync();
        }

        public async Task<List<Appointments>> GetByMasterAndDateAsync(Guid masterId, DateTime date)
        {
            return await _dbContext.Appointments.Where(x => x.MasterId == masterId && x.AppointmentDate == date).ToListAsync();
        }    
    }
}