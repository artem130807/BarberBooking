using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoVo;

namespace BarberBooking.API.Dto.DtoSalons
{
    public class DtoSalonCreateInfo
    {
        public Guid Id {get; set;}
        public string Name {get; set;}
        public string Description { get; set; }
        public DtoAddress DtoAddress {get; set;}
        public DtoPhone Phone {get ; set;}
    }
}