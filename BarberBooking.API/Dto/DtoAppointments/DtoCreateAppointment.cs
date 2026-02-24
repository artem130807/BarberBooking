using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Domain.ValueObjects;

namespace BarberBooking.API.Dto.DtoAppointments
{
    public class DtoCreateAppointment
    {
        public Guid SalonId { get;  set; }
        public Guid MasterId { get;  set; }
        public Guid ServiceId { get; set; }
        public Guid TimeSlotId { get; set; }
        public string? ClientNotes {get; set;}
        public TimeOnly StartTime { get;  set; } 
        public DateTime AppointmentDate {get; set;} 
    }
}