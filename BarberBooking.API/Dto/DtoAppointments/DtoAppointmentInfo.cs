using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Domain.ValueObjects;

namespace BarberBooking.API.Dto.DtoAppointments
{
    public class DtoAppointmentInfo
    {
        public Guid Id {get; private set;}
        public Guid SalonId { get; private set; }
        public Guid MasterId { get; private set; }
        public Guid ServiceId { get; private set; }
        public Guid TimeSlotId { get; private set; }
        public TimeSpan StartTime { get; private set; } 
        public TimeSpan EndTime { get; private set; } 
        public string ClientName { get; private set; }
        public PhoneNumber ClientPhone { get; private set; }
        public DateTime AppointmentDateTime { get; private set; }
        public string? ClientComment { get; private set; }
        public DateTime CreatedAt { get; private set; } = DateTime.UtcNow;
        public DateTime UpdatedAt { get; private set; } = DateTime.UtcNow;
    }
}