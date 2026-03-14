using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Domain.ValueObjects;
using BarberBooking.API.Dto.DtoMasterProfile;
using BarberBooking.API.Dto.DtoSalons;
using BarberBooking.API.Dto.DtoServices;
using BarberBooking.API.Enums;

namespace BarberBooking.API.Dto.DtoAppointments
{
    public class DtoClientAppointmentInfo
    {
        public Guid Id { get; private set; } 
        public string? ClientNotes {get; private set;}
        public Guid SalonId { get; private set; }
        public string SalonName { get; private set;}
        public DtoMasterProfileNavigation dtoMasterProfileNavigation {get; private set;}
        public DtoServicesNavigation dtoServicesNavigation {get; private set;}
        public AppointmentStatusEnum Status {get; private set;} = AppointmentStatusEnum.Confirmed;
        public TimeOnly StartTime { get; private set; }
        public TimeOnly EndTime { get; private set; } 
        public DateTime AppointmentDate {get; private set;} 
    }
}