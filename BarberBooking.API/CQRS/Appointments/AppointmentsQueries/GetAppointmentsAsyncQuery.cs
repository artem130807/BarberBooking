using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoAppointments;
using MediatR;

namespace BarberBooking.API.CQRS.AppointmentsQueries
{
    public record GetAppointmentsAsyncQuery():IRequest<List<DtoAppointmentInfo>>;
   
}