using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoVo
{
    public class DtoAddress
    {
        public string City {get; set;}
        public string Street {get; set;}
        public string HouseNumber{get; set;}
        public string Apartment {get; set;}
    }
}