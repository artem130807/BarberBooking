using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoServices
{
    public class DtoServicesNavigation
    {
        public Guid Id { get; private set; } 
        public string Name { get; private set; }
        public DtoPrice Price { get; private set; }
    }
}