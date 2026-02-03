using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Domain.ValueObjects;

namespace BarberBooking.API.Dto.DtoServices
{
    public class DtoServicesInfo
    {
        public Guid Id {get; private set;}
        public string Name { get;  set; }
        public string? Description { get; set; }
        public int DurationMinutes { get;  set; } 
        public Price Price { get;  set; }
        public string? PhotoUrl { get; private set; }
        public bool IsActive { get;  set; } = true;
    }
}