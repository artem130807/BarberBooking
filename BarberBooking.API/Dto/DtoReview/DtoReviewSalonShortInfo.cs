using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoMasterProfile;

namespace BarberBooking.API.Dto.DtoReview
{ 
    public class DtoReviewSalonShortInfo
    {
        public Guid Id { get; private set;}
        public DtoMasterProfileNavigation DtoMasterProfileNavigation {get; private set;}
        public string UserName {get; private set;}
        public int? SalonRating {get; private set;}
        public int? MasterRating {get; private set;}
        public string? Comment { get; private set; }
        public DateTime CreatedAt { get; private set; } = DateTime.UtcNow;
    }
}