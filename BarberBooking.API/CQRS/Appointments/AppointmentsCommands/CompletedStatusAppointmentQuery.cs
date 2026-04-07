using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Appointments.AppointmentsCommands
{
    public record CompletedStatusAppointmentQuery(Guid appointmentId):IRequest<Result<string>>;
}