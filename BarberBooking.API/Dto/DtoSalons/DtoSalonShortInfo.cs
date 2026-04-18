using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoVo;

namespace BarberBooking.API.Dto.DtoSalons
{
    public class DtoSalonShortInfo
    {
        public Guid Id {get; set;}
        public string Name {get;  set;}
        public string MainPhotoUrl { get; set; }
        public decimal Rating {get;  set;}
        public int RatingCount {get;  set;}
        public int AvailableSlots {get; set;}
        public DtoAddressShort Address {get; set;}
    }
}