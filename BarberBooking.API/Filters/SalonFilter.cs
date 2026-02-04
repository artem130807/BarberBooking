using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Domain.ValueObjects;
using Microsoft.EntityFrameworkCore.Storage.ValueConversion;

namespace BarberBooking.API.Filters
{
    public class SalonFilter
    {
        public bool? IsActive {get; set;}
        public decimal? Rating {get; set;}
    }
}