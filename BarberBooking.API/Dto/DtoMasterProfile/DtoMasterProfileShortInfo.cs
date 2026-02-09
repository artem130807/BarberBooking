using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoMasterProfile
{
    public class DtoMasterProfileShortInfo
    {
        public Guid Id {get; private set;}
        public string UserName { get; private set; }
        public string? Specialization { get; private set; }
        public string? AvatarUrl { get; private set; }
        public decimal Rating {get; private set;}
    }
}