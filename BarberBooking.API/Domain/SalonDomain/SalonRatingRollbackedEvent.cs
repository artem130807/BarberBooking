using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace BarberBooking.API.Domain.SalonDomain
{
    public class SalonRatingRollbackedEvent:DomainEvent
    {
        public decimal PreviousRating {get; set;}
        public int PreviousRatingCount {get;  set;}
        [JsonConstructor]
        private SalonRatingRollbackedEvent(){}
        public SalonRatingRollbackedEvent(Guid salonId,  decimal previousRating, 
        int previousRatingCount)
        {
            AggregateId = salonId;
            PreviousRating = previousRating;
            PreviousRatingCount = previousRatingCount;
        }
        
    }
}