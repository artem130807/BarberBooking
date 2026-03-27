using System;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.AppointmentsFilter;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Appointments.AppointmentsQueries
{
    public record GetSalonAppointmentsPagedQuery(Guid salonId, DateTime? from, DateTime? to, FilterAppointments filter,PageParams pageParams) : IRequest<Result<PagedResult<DtoSalonAppointmentAdmin>>>;
}
