using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoSalonPhotos
{
    public class DtoSalonPhoto
    {
        public Guid Id { get; set; }
        public string? PhotoUrl { get; set; }
    }
}