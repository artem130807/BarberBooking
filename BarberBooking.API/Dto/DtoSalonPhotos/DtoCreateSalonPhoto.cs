using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoSalonPhotos
{
    public class DtoCreateSalonPhoto
    {
        public string? PhotoUrl {get; set;}
        public Guid SalonId {get; set;}
    }
}