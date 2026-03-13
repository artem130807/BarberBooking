using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoSalons;

namespace BarberBooking.API.Dto.DtoServices
{
    public class DtoServicesSearchResult
    {
        public Guid Id {get; private set;}
        public string Name { get; private set; }
        public int DurationMinutes { get; private set; } 
        public DtoPrice Price { get; private set; }
        public string? PhotoUrl { get; private set; }
        public DtoSalonNavigation dtoSalonNavigation {get; private set;}
    }
}