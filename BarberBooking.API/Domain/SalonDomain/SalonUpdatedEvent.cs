using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Domain.ValueObjects;

namespace BarberBooking.API.Domain.SalonDomain
{
    public class SalonUpdatedEvent:DomainEvent
    {
        public string Name {get;}
        public string? Description { get;}
        public Address Address {get;}
        public PhoneNumber? PhoneNumber {get;}
        public string? MainPhotoUrl { get;}
        public decimal Rating {get;}
        public int RatingCount {get;}
        public SalonUpdatedEvent(Guid salonId, string name, string description, Address address, PhoneNumber? phoneNumber, string? mainPhotoUrl, decimal rating, int ratingCount)
        {
            AggregateId = salonId;
            Name = name;
            Description = description;
            Address = address;
            PhoneNumber = phoneNumber;
            MainPhotoUrl = mainPhotoUrl;
            Rating = rating;
            RatingCount = ratingCount;
        }
    }
}