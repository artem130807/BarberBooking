using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoAppointments;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Appointments.AppointmentsQueries
{
    public record GetAppointmentsByMasterIdAndDateQuery(DateTime appointmentDateTime):IRequest<Result<List<DtoMasterAppointmentShortInfo>>>;
}