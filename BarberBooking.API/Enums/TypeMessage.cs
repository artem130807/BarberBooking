using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Enums
{
    public enum TypeMessage
    {
        CreationAppointment,
        CompletedAppointment,
        Reminder,
        Promotion,
        CancelledAppointment
    }
}