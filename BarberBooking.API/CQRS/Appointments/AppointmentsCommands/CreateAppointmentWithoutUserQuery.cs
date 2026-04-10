using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoAppointments;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Appointments.AppointmentsCommands
{
    public record CreateAppointmentWithoutUserQuery(DtoCreateAppointment dtoCreateAppointment):IRequest<Result<string>>;
}