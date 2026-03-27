using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.SalonStatisctic.Queries;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.Filters.Salon
{
    public class SalonStatisticsFilter
    {
        public Guid? SalonId {get; set;}
        public int? Day {get; set;}
    }
}