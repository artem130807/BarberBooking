using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoAppointments;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.AppointmentsCommands
{
    public record CreateAppointmentCommand(DtoCreateAppointment DtoCreateAppointment):IRequest<Result<string>>;
}