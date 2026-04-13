using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoSalons;

namespace BarberBooking.API.Dto.DtoSalonAdmin
{
    public class DtoGetSalonAdmin
    {
        public Guid Id {get; private set;}
        public DtoSalonNavigation dtoSalonNavigation {get; private set;}
    }
}