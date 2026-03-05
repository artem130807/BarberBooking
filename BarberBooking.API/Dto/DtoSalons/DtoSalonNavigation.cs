using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoVo;

namespace BarberBooking.API.Dto.DtoSalons
{
    public class DtoSalonNavigation
    {
        public Guid Id {get; set;}
        public string SalonName {get; set;}
        public DtoAddress Address{get; private set;}
        public string? MainPhotoUrl { get; private set; }
        public decimal Rating {get; private set;}
        public int RatingCount {get; private set;}
    }
}