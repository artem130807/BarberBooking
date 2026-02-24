using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoReview
{
    public class DtoReviewInfo
    {
        public Guid Id {get; set;}
        public Guid AppointmentId { get; set; }
        public Guid ClientId { get; set; }
        public Guid SalonId { get; set; }
        public Guid? MasterProfileId { get; set; }
        public int SalonRating { get; set; } 
        public int? MasterRating {get; set;}
        public string? Comment { get; set; }
    }
}