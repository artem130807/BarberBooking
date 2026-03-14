using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoReview
{
    public class DtoUpdateReview
    {
        public int? SalonRating { get; set; } 
        public int? MasterRating {get; set;}
        public string? Comment { get;  set; }
    }
}