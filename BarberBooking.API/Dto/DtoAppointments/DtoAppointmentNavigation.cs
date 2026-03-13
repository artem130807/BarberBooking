using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoServices;

namespace BarberBooking.API.Dto.DtoAppointments
{
    public class DtoAppointmentNavigation
    {
        public Guid Id {get; private set;}
        public string ServiceName {get; private set;}
        public DtoPrice Price {get; private set;}
        public string? PhotoUrl { get; private set; }
    }
}