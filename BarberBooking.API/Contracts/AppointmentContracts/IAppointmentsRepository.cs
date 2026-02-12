using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts
{
    public interface IAppointmentsRepository
    {
        Task<Appointments> CreateAsync(Appointments appointments);
        Task DeleteAsync(Guid Id);
        Task<Appointments?> GetByIdAsync(Guid id);
        Task<List<Appointments>> GetAppointmentsAsync();
        Task<List<Appointments>> GetByMasterTodayAsync(Guid masterId);
        Task<Appointments?> GetByMasterAndDateTimeAsync(Guid masterId ,DateTime appointmentDateTime);
        Task<List<Appointments>> GetByMasterAndDateAsync(Guid masterId, DateTime date);
        Task<Appointments> GetByClientIdAndDateAsync(DateTime appointmentDateTime, Guid clientId);
        Task<Appointments> GetByIdAndUserIdAsync(Guid Id, Guid ClientId);
    }
}