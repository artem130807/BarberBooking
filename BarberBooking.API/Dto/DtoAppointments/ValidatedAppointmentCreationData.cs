using BarberBooking.API.Models;

namespace BarberBooking.API.Dto.DtoAppointments
{
    public sealed record ValidatedAppointmentCreationData(Appointments MappedAppointment, TimeOnly EndTime);
}
