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
    public record GetAppointmentsByTimeSlotQuery(Guid timeSlotId, PageParams pageParams, StatusFilter filter):IRequest<Result<PagedResult<DtoMasterAppointmentShortInfo>>>;
}