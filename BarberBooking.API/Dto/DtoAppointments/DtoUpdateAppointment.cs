using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Domain.ValueObjects;
using BarberBooking.API.Enums;

namespace BarberBooking.API.Dto.DtoAppointments
{
    public class DtoUpdateAppointment
    { 
        public Guid? ServiceId { get;  set; }
        public TimeSpan? StartTime { get;  set; } 
        public TimeSpan? EndTime { get;  set; } 
        public string? ClientNotes { get; set; }
        public AppointmentStatusEnum? Status {get; set;}
    }
}