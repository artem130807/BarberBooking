using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace BarberBooking.API.Domain.SalonDomain
{
    public class SalonAddRatingEvent:DomainEvent
    {
        public decimal Rating {get; set;}
        public int RatingCount {get; set;}
        [JsonConstructor]
        private SalonAddRatingEvent(){}
        public SalonAddRatingEvent(Guid salonId, decimal rating, int ratingCount)
        {
            AggregateId = salonId;
            Rating = rating;
            RatingCount = ratingCount;
        }
       
        
    }
}