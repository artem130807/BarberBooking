using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.AppointmentsFilter;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Appointments.AppointmentsQueries
{
    public record GetAppointmentsByMasterIdQuery(FilterAppointments filter ,PageParams pageParams):IRequest<Result<PagedResult<DtoMasterAppointmentShortInfo>>>;
}