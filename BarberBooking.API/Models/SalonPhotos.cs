using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Models
{
    public class SalonPhotos
    {
        public Guid Id {get; private set;}
        public string? PhotoUrl {get; private set;}
        public Guid SalonId {get; private set;}
        public Salons Salon {get; private set;}
        public DateTime CreatedAt {get; private set;}
    }
}