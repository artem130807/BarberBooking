using System;
using BarberBooking.API.Dto.DtoMasterProfile;
using BarberBooking.API.Dto.DtoServices;
using BarberBooking.API.Dto.DtoUsers;

namespace BarberBooking.API.Dto.DtoAppointments
{
    public class DtoSalonAppointmentAdmin
    {
        public Guid Id { get; private set; }
        public Guid ClientId { get; private set; }
        public Guid MasterId { get; private set; }
        public Guid ServiceId { get; private set; }
        public Guid SalonId { get; private set; }
        public string SalonName { get; private set; }
        public string? ClientNotes { get; private set; }

        public DtoUsersNavigation dtoUsersNavigation { get; private set; }
        public DtoMasterProfileNavigation dtoMasterProfileNavigation { get; private set; }
        public DtoServicesNavigation dtoServicesNavigation { get; private set; }

        public string Status { get; private set; }

        public TimeOnly StartTime { get; private set; }
        public TimeOnly EndTime { get; private set; }
        public DateTime AppointmentDate { get; private set; }
        public DateTime CreatedAt { get; private set; }
        public DateTime UpdatedAt { get; private set; }
    }
}
