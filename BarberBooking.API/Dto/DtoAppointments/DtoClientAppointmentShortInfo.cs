using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoMasterProfile;
using BarberBooking.API.Dto.DtoSalons;
using BarberBooking.API.Dto.DtoServices;
namespace BarberBooking.API.Dto.DtoAppointments
{
    public class DtoClientAppointmentShortInfo
    {
        public Guid Id {get; private set;}
        public DtoSalonNavigation SalonNavigation {get; private set;}
        public DtoMasterProfileNavigation MasterProfileNavigation {get; private set;}
        public string ServiceName {get; private set;}
        public TimeOnly StartTime { get; private set; }
        public TimeOnly EndTime { get; private set; } 
        public DtoPrice Price {get; private set;}
        public DateTime AppointmentDate {get; private set;} 
        public string Status { get; set; }
    }
}