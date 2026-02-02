using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoAppointments;
using MediatR;

namespace BarberBooking.API.CQRS.AppointmentsCommands
{
    public record UpdateAppointmentCommand(Guid Id, DtoUpdateAppointment dtoUpdateAppointment):IRequest<DtoAppointmentInfo>;
    
}