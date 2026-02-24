using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;

namespace BarberBooking.API.Domain.ReviewDomain
{
    public class ReviewCreatedEvent:DomainEvent
    {
        public Guid AppointmentId {get;}
        public Guid ClientId { get; }
        public Guid SalonId { get; }
        public Guid? MasterProfileId { get; }
        public int SalonRating { get;} 
        public int? MasterRating {get;}
        public string? Comment { get;}
        public ReviewCreatedEvent(Guid reviewId, Guid appointmentId, Guid clientId ,Guid salonId, Guid? masterProfileId, int salonRating, int? masterRating, string? comment)
        {
            AggregateId = reviewId;
            ClientId = clientId;
            AppointmentId = appointmentId;
            SalonId = salonId;
            MasterProfileId = masterProfileId;
            SalonRating = salonRating;
            MasterRating = masterRating;
            Comment = comment;
        }
        private ReviewCreatedEvent(){}
    }
}