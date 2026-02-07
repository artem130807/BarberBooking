using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using BarberBooking.API.Domain.ValueObjects;

namespace BarberBooking.API.Models
{
    public class Salons
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
        public string? MainPhotoUrl { get; private set; }
        public decimal Rating {get; private set;}
        public int RatingCount {get; private set;}
        public ICollection<MasterProfile> SalonUsers {get; private set;}
        public ICollection<Appointments> Appointments {get; private set;}
        public ICollection<Services> Services {get; private set;}
        public ICollection<Review> Reviews { get; private set; }
        private Salons()
        {
            SalonUsers = new List<MasterProfile>();
            Appointments = new List<Appointments>();
            Services = new List<Services>();
            Reviews = new List<Review>();
        }
        public static Salons Create(string name, string description, Address address, PhoneNumber? phoneNumber ,TimeOnly? openingTime,  TimeOnly? closingTime , string? mainPhotoUrl)
        {
            var salon = new Salons
            {
                Id = Guid.NewGuid(),
                Name = name,
                Description = description,
                Address = address,
                PhoneNumber = phoneNumber,
                OpeningTime = openingTime,
                ClosingTime = closingTime,
                IsActive = true,
                MainPhotoUrl = mainPhotoUrl,
                Rating = 0,
                RatingCount = 0,
                CreatedAt = DateTime.UtcNow
            };
            return salon;
        }
        public void UpdateName(string name) => Name = name;
        public void UpdateDescription(string description) => Description = description;
        public void UpdateOpeningTime(TimeOnly? openingTime) => OpeningTime = openingTime;
        public void UpdateClosingTime(TimeOnly? closingTime) => ClosingTime = closingTime;
        public void UpdateAddress(Address address) => Address = address;
        public void UpdatePhoneNumber(PhoneNumber phoneNumber) => PhoneNumber = phoneNumber;
        public void UpdateMainPhotoUrl(string mainPhotoUrl) => MainPhotoUrl = mainPhotoUrl;
        public void UpdateIsActive(bool isActive) => IsActive = isActive;
        public void AddRating(int rating)
        {
            Rating = rating;
            RatingCount++;
        }
    }
}