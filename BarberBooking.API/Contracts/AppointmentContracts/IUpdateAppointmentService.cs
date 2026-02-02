using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts
{
    public interface IUpdateAppointmentService
    {
        Task UpdateAsync(Appointments appointments,DtoUpdateAppointment dto);
    }
}