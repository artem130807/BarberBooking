using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Domain.ValueObjects;

namespace BarberBooking.API.Dto.DtoServices
{
    public class DtoCreateServices
    {
        public Guid SalonId { get;  set; }
        public string Name { get;  set; }
        public string? Description { get;  set; }
        public int DurationMinutes { get;  set; } 
        public DtoPrice Price { get;  set; }
        public string? PhotoUrl { get; set; }
        public string? MainPhotoUrl { get; private set; }
    }
}