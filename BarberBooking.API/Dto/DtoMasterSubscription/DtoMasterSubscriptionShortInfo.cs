using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoMasterProfile;

namespace BarberBooking.API.Dto.DtoMasterSubscription
{
    public class DtoMasterSubscriptionShortInfo
    {
        public Guid Id {get; private set;}
        public DtoMasterProfileSubscriptionInfo masterProfileNavigation {get; private set;}
    }
}