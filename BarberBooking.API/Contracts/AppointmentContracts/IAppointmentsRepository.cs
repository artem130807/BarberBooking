using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Enums;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.AppointmentsFilter;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts
{
    public interface IAppointmentsRepository
    {
        Task<Appointments> CreateAsync(Appointments appointments);
        Task StatusUpdateRange(Guid timeSlotId, AppointmentStatusEnum status);
        Task DeleteAsync(Guid Id);
        Task<Appointments> GetByIdAsync(Guid id);
        Task<Appointments> GeAppointmentByMasterIdAndDate(Guid masterId, DateTime date);
        Task<List<Appointments>> GetAppointmentsByClientId(Guid clientId);
        Task<PagedResult<Appointments>> GetAppointmentsByMasterId(Guid masterId, FilterAppointments filter ,PageParams pageParams);
        Task<List<Appointments>> GetAppointmentsBySalonId(Guid salonId);
        Task<int> GetCountAppointmentsBySalonId(Guid salonId);
        Task<List<Appointments>> GetByClientIdAndDate(Guid clientId, DateTime appointmentDateTime);
        Task<PagedResult<Appointments>> GetCompletedAppointmentsByClientId(Guid clientId, PageParams pageParams);
        Task<Appointments> GetByMasterIdAndDate(Guid masterId, DateTime appointmentDateTime, TimeOnly startTime);
        Task<List<Appointments>> GetConfirmedAppointmentsInRange(DateTime from, DateTime to);
        Task<List<Appointments>> GetConfirmedAppointmentsCreatedSince(DateTime sinceUtc);
        Task<PagedResult<Appointments>> GetAllAppointments(Guid salonId, FilterAppointments? filter,PageParams pageParams);
        Task<Appointments> GetAppointmentActive(Guid timeSlotId);
        Task<List<Appointments>> GetAppointmentsByTimeSlotId(Guid timeSlotId);
    }
}
