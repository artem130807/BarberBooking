using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoAppointments
{
    public class DtoCreateAppointmentInfo
    {
        public Guid Id {get; set;}
        public Guid SalonId { get;  set; }
        public Guid MasterId { get;  set; }
        public Guid ClientId {get; set;}
        public Guid ServiceId { get; set; }
        public Guid TimeSlotId { get; set; }
        public string? ClientNotes {get; set;}
        public TimeOnly StartTime { get;  set; } 
        public DateTime AppointmentDate {get; set;} 
    }
}