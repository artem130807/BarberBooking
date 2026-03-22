using System;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Appointments.AppointmentsQueries
{
    public record GetSalonAppointmentsPagedQuery(Guid salonId, DateTime? from, DateTime? to, PageParams pageParams) : IRequest<Result<PagedResult<DtoSalonAppointmentAdmin>>>;
}
