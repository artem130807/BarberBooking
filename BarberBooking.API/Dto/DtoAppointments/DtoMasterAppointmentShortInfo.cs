using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoServices;

namespace BarberBooking.API.Dto.DtoAppointments
{
    public class DtoMasterAppointmentShortInfo
    {
        public Guid Id {get; private set;}
        public string UserName {get; private set;}
        public string ServiceName {get; private set;}
        public TimeOnly StartTime { get; private set; }
        public TimeOnly EndTime { get; private set; } 
        public DtoPrice Price {get; private set;}
        public DateTime AppointmentDate {get; private set;}
        public string Status { get; private set; }
        public bool CreatedWithoutApp { get; private set; }
    }
}