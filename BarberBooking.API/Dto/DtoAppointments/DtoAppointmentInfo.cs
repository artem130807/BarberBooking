using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Domain.ValueObjects;
using BarberBooking.API.Enums;

namespace BarberBooking.API.Dto.DtoAppointments
{
    public class DtoAppointmentInfo
    {
        public Guid Id { get; private set; } 
        public Guid SalonId { get; private set; }
        public Guid ClientId {get; private set;}
        public Guid MasterId { get; private set; }
        public Guid ServiceId { get; private set; }
        public Guid TimeSlotId { get; private set; }
        public string? ClientNotes {get; private set;}
        public AppointmentStatusEnum Status {get; private set;} = AppointmentStatusEnum.Pending;
        public TimeOnly StartTime { get; private set; }
        public TimeOnly EndTime { get; private set; } 
        public DateTime AppointmentDate {get; private set;} 
    }
}