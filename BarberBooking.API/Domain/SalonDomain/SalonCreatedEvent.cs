using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Domain.ValueObjects;

namespace BarberBooking.API.Domain.SalonDomain
{
    public class SalonCreatedEvent:DomainEvent
    {
        public string Name {get;}
        public string? Description { get;}
        public Address Address {get;}
        public PhoneNumber? PhoneNumber {get;}
        public string? MainPhotoUrl { get;}
        public TimeOnly? OpeningTime {get;}
        public TimeOnly? ClosingTime {get;}
        public SalonCreatedEvent(Guid salonId, string name, string description, Address address, PhoneNumber? phoneNumber,TimeOnly? openingTime,  TimeOnly? closingTime ,string? mainPhotoUrl)
        {
            AggregateId = salonId;
            Name = name;
            Description = description;
            Address = address;
            PhoneNumber = phoneNumber;
            MainPhotoUrl = mainPhotoUrl;
            OpeningTime = openingTime;
            ClosingTime = closingTime;
        }
        private SalonCreatedEvent(){}
    }
}