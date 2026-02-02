using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoMasterProfile
{
    public class DtoUpdateMasterProfile
    {
        public string? Bio { get; set; }
        public string? Specialization { get; set; }
        public string? AvatarUrl { get; set; }
    }
}