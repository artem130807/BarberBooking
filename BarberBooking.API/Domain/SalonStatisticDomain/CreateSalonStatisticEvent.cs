using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace BarberBooking.API.Domain.SalonStatisticDomain
{
    public class CreateSalonStatisticEvent:DomainEvent
    {
        public Guid SalonId {get;}
        public int CompletedAppointmentsCount {get;}
        public int CancelledAppointmentsCount {get;}
        public double SumPrice {get;}
        public decimal Rating {get;}
        public int RatingCount {get;}
        public DateTime CreatedAt {get;}

        [JsonConstructor]
        private CreateSalonStatisticEvent(){}
        public CreateSalonStatisticEvent(Guid statisticId, Guid salonId, int completedAppointmentsCount, int cancelledAppointmentsCount,  double sumPrice, decimal rating, int ratingCount)
        {
            AggregateId = statisticId;
            SalonId = salonId;
            CompletedAppointmentsCount = completedAppointmentsCount;
            CancelledAppointmentsCount = cancelledAppointmentsCount;
            SumPrice = sumPrice;
            Rating = rating;
            RatingCount = ratingCount;
            CreatedAt = DateTime.UtcNow;
        }
    }
}