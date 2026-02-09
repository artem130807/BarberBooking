using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoMasterProfile
{
    public class DtoCreateProfileInfo
    {
        public Guid Id {get; private set;}
        public Guid UserId { get; private set; }
        public Guid SalonId {get; private set;}
        public string? Bio { get; private set; }
        public string? Specialization { get; private set; }
        public string? AvatarUrl { get; private set; }
    }
}