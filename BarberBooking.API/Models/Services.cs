using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Domain.ValueObjects;

namespace BarberBooking.API.Models
{
    public class Services
    {
        public Guid Id { get; private set; } 
        public Guid SalonId { get; private set; }
        public string Name { get; private set; }
        public string? Description { get; private set; }
        public int DurationMinutes { get; private set; } 
        public Price Price { get; private set; }
        public string? PhotoUrl { get; private set; }
        public bool IsActive { get; private set; } = true;
        public DateTime CreatedAt { get; private set; } = DateTime.UtcNow;      
        public  Salons Salon { get; private set; } 
        public ICollection<Appointments> Appointments { get; private set; } 
        public ICollection<MasterServices> MasterServices {get; private set;}
        private Services()
        {
            Appointments = new List<Appointments>();
            MasterServices = new List<MasterServices>();
        }
        public static Services Create(Services services)
        {
            var service = new Services
            {
                Id = Guid.NewGuid(),
                SalonId = services.SalonId,
                Name = services.Name,
                Description = services.Description,
                DurationMinutes = services.DurationMinutes,
                Price = services.Price,
                PhotoUrl = services.PhotoUrl,
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };
            return service;
        }
        public static Services Create(Guid salonId, string name, string? description, int durationMinutes, Price price, string? photoUrl)
        {
            var service = new Services
            {
                Id = Guid.NewGuid(),
                SalonId = salonId,
                Name = name,
                Description = description,
                DurationMinutes = durationMinutes,
                Price = price,
                PhotoUrl = photoUrl,
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };
            return service;
        }
        public void UpdateName(string name) => Name = name;
        public void UpdateDescription(string description) => Description = description;
        public void UpdateDurationMinutes(int durationMinutes) => DurationMinutes = durationMinutes;
        public void UpdatePhoto(string photo) => PhotoUrl = photo;
        public void UpdatePrice(Price price) => Price = price;
        public void UpdateIsActive(bool isActive) => IsActive = isActive;
    }
}