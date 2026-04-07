using System;
using System.Globalization;

namespace BarberBooking.API.Helpers
{
    public static class AppointmentMessageFormatting
    {
        public static string FormatForMessage(DateTime appointmentDate)
        {
            return appointmentDate.ToString("dd.MM.yyyy HH:mm", CultureInfo.InvariantCulture);
        }
    }
}
