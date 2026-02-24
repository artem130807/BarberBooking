using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace BarberBooking.API.Domain.MasterDomain
{
    public class MasterRollBackRatingEvent:DomainEvent
    {
        public decimal PreviousRating {get; set;}
        public int PreviousRatingCount {get;  set;}
        [JsonConstructor]
        private MasterRollBackRatingEvent(){}
        public MasterRollBackRatingEvent(Guid masterId, decimal previousRating, int previousRatingCount)
        {
            AggregateId = masterId;
            PreviousRating = previousRating;
            PreviousRatingCount = previousRatingCount;
        }
    }
}