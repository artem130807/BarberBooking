using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoMasterProfile
{
    public class DtoCreateMasterProfile
    {
        public Guid UserId { get; set; }
        public Guid SalonId {get; set;}
        public string? Bio { get; set; }
        public string? Specialization { get; set; }
        public string? AvatarUrl { get; set; }
    }
}