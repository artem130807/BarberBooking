using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoMasterProfile
{
    public class DtoMasterPhotoAndName
    {
        public Guid Id {get; set;}
        public string? AvatarUrl { get; set; }
        public string UserName {get; set;}
        public decimal Rating {get; set;}
    }
}