using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoServices
{
    public class DtoServicesShortInfo
    {
        public string Name { get; private set; }
        public int DurationMinutes { get; private set; }
        public DtoPrice Price { get; private set; }
    }
}