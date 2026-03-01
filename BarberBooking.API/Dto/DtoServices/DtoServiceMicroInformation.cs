using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoServices
{
    public class DtoServiceMicroInformation
    {
        public Guid Id {get; set;}
        public string Name {get; set;}
        public string? PhotoUrl { get; set; }
    }
}