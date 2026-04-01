using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoSalons;

namespace BarberBooking.API.Dto.DtoMasterProfile
{
    public class DtoMasterProfileInfo 
    {
        public Guid Id {get; private set;}
        public string UserName {get; private set;}
        public DtoSalonNavigation SalonNavigation {get; private set;}
        public string? Bio { get; private set; }
        public string? Specialization { get; private set; }
        public string? AvatarUrl { get; private set; }
        public decimal Rating {get; private set;}
        public int RatingCount {get; private set;}
        public string? MasterPhone {get; private set;}
        public bool IsSubscripe {get; set;}
    }
}