using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Domain.ValueObjects;

namespace BarberBooking.API.Dto.DtoServices
{
    public class DtoUpdateServices
    {
        public string? Name { get;  set; }
        public string? Description { get;  set; }
        public int? DurationMinutes { get;  set; } 
        public DtoUpdatePrice? Price { get;  set; }
        public string? Photo {get; set;}
        public bool? IsActive { get;  set; } 
    }
}