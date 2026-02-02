using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoVo;

namespace BarberBooking.API.Dto.DtoSalons
{
    public class DtoSalonShortInfo
    {
        public string Name {get; private set;}
        public string? MainPhotoUrl { get; private set; }
        public decimal Rating {get; private set;}
        public int RatingCount {get; private set;}
        public DtoAddressShort Address {get; private set;}
    }
}