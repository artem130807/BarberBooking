using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoMasterProfile;
using BarberBooking.API.Dto.DtoSalons;
using BarberBooking.API.Dto.DtoServices;

namespace BarberBooking.API.Dto.DtoAppointments
{
    public class DtoAppointmentAwaitingReview
    {
        public Guid Id {get; private set;}
        public DtoServicesNavigation dtoServicesNavigation {get; private set;}
        public DtoMasterProfileNavigation dtoMasterProfileNavigation {get; private set;}
        public DtoSalonNavigation dtoSalonNavigation {get; private set;}
        public DateTime AppointmentDate {get; private set;} 
    }
}