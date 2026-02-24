using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace BarberBooking.API.Domain.MasterDomain
{
    public class MasterAddRatingEvent:DomainEvent
    {
        public decimal Rating {get; set;}
        public int RatingCount {get; set;}
        [JsonConstructor]
        private MasterAddRatingEvent(){}
        public MasterAddRatingEvent(Guid masterId ,decimal rating, int ratingCount)
        {
            AggregateId = masterId;
            Rating = rating;
            RatingCount = ratingCount;
        }
    }
}