using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using BarberBooking.API.Domain;
using BarberBooking.API.Domain.SalonDomain;
using BarberBooking.API.Domain.ValueObjects;

namespace BarberBooking.API.Models
{
    public class Salons:AggregateRoot
    {
        public Guid Id {get; private set;}
        public string Name {get; private set;}
        public string? Description { get; private set; }
        public Address Address {get; private set;}
        public PhoneNumber? PhoneNumber {get; private set;}
        public DateTime CreatedAt {get; private set;} = DateTime.Now;
        public TimeOnly? OpeningTime { get; private set; }
        public TimeOnly? ClosingTime { get; private set; }
        public bool IsActive {get; private set;} = true;
        public decimal Rating {get; private set;}
        public int RatingCount {get; private set;}
        public ICollection<MasterProfile> SalonUsers {get; private set;}
        public ICollection<Appointments> Appointments {get; private set;}
        public ICollection<Services> Services {get; private set;}
        public ICollection<Review> Reviews { get; private set; }
        public ICollection<SalonStatistic> SalonStatistics {get; private set;}
        public ICollection<SalonsAdmin> SalonsAdmins {get; private set;}
        public ICollection<SalonPhotos> SalonPhotos {get; private set;}
        
        private Salons()
        {
            SalonUsers = new List<MasterProfile>();
            Appointments = new List<Appointments>();
            Services = new List<Services>();
            Reviews = new List<Review>();
            SalonStatistics = new List<SalonStatistic>();
            SalonsAdmins = new List<SalonsAdmin>();
            SalonPhotos = new List<SalonPhotos>();
        }
        public static Salons Create(string name, string description, Address address, PhoneNumber? phoneNumber ,TimeOnly? openingTime,  TimeOnly? closingTime)
        {
           var salon = new Salons();
            salon.ApplyChange(new SalonCreatedEvent(
                Guid.NewGuid(),
                name,
                description,
                address,
                phoneNumber,
                openingTime,
                closingTime
            ));
            
            return salon;
        }
        public void UpdateName(string name) => Name = name;
        public void UpdateDescription(string description) => Description = description;
        public void UpdateOpeningTime(TimeOnly? openingTime) => OpeningTime = openingTime;
        public void UpdateClosingTime(TimeOnly? closingTime) => ClosingTime = closingTime;
        public void UpdateAddress(Address address) => Address = address;
        public void UpdatePhoneNumber(PhoneNumber phoneNumber) => PhoneNumber = phoneNumber;
        public void UpdateIsActive(bool isActive) => IsActive = isActive;
        public void AddRating(decimal rating, int ratingCount)
        {
            ApplyChange(new SalonAddRatingEvent(Id, rating, ratingCount));
        }
        public void RollBackRating(decimal previousRating, int previousRatingCount)
        {
            ApplyChange(new SalonRatingRollbackedEvent(Id, previousRating, previousRatingCount));
        }
        private void Apply(SalonCreatedEvent @event)
        {
            Id = @event.AggregateId;
            Name = @event.Name;
            Description = @event.Description;
            Address = @event.Address;
            PhoneNumber = @event.PhoneNumber;
            OpeningTime = @event.OpeningTime;
            ClosingTime = @event.ClosingTime;
            IsActive = true;
            Rating = 0;
            RatingCount = 0;
            CreatedAt = DateTime.UtcNow;
            SalonUsers = new List<MasterProfile>();
            Appointments = new List<Appointments>();
            Services = new List<Services>();
            Reviews = new List<Review>();
            SalonsAdmins = new List<SalonsAdmin>();
            SalonPhotos = new List<SalonPhotos>();
        }
        private void Apply(SalonAddRatingEvent @event)
        {
            Rating = @event.Rating;
            RatingCount = @event.RatingCount;
        }
        private void Apply(SalonRatingRollbackedEvent @event)
        {
            Rating = @event.PreviousRating;
            RatingCount = @event.PreviousRatingCount;
        }
    }
}