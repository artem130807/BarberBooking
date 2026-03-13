using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoSalons;

namespace BarberBooking.API.Dto.DtoMasterProfile
{
    public class DtoMasterProfileSubscriptionInfo
    {
        public Guid Id {get; private set;}
        public string MasterName {get; private set;}
        public string? AvatarUrl { get; private set; }
        public decimal Rating {get; private set;}
        public DtoSalonNavigation SalonNavigation {get; private set;}
    }
}