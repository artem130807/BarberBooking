using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoAppointments
{
    public class DtoAppointmentShortInfo
    {
        public Guid Id {get; private set;}
        public string ClientName {get; private set;}
        public string MasterName {get; private set;}
        public DtoPhone ClientPhone {get; private set;}
        public TimeOnly StartTime { get; private set; }
        public TimeOnly EndTime { get; private set; } 
        public DateTime AppointmentDate {get; private set;} 
    }
}