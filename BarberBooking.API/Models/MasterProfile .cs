using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Domain.ValueObjects;

namespace BarberBooking.API.Models
{
    public class MasterProfile 
    {
        public Guid Id {get; private set;}
        public Guid UserId { get; private set; }
        public Guid SalonId {get; private set;}
        public string? Bio { get; private set; }
        public string? Specialization { get; private set; }
        public string? AvatarUrl { get; private set; }
        public decimal Rating {get; private set;}
        public int RatingCount {get; private set;}
        public Salons Salon {get; private set;}
        public Users User {get; private set;}
        public  ICollection<MasterTimeSlot> TimeSlots{ get; private set; } 
        public  ICollection<Appointments> Appointments { get; private set; } 
        public ICollection<MasterSubscription> Subscriptions { get; private set; }
        public ICollection<Review> Reviews { get; private set; }
        public ICollection<WeeklyTemplate> WeeklyTemplates {get; private set;}
        public DateTime CreatedAt {get; private set;} = DateTime.UtcNow;

        private MasterProfile()
        {
            TimeSlots = new List<MasterTimeSlot>();
            Appointments = new List<Appointments>();
            Subscriptions = new List<MasterSubscription>();
            Reviews = new List<Review>();
            WeeklyTemplates = new List<WeeklyTemplate>();
        }
        public static MasterProfile Create(Guid userId, Guid salonId, string? bio, string? specialization, string? avatarUrl)
        {
            var master = new MasterProfile
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                SalonId = salonId,
                Bio = bio,
                Specialization = specialization,
                AvatarUrl = avatarUrl,
                Rating = 0,
                RatingCount = 0,
                CreatedAt = DateTime.UtcNow
            };
            return master;
        }
        public void UpdateBio(string bio) => Bio = bio;
        public void UpdateSpecialization(string specialization) => Specialization = specialization;
        public void UpdateAvatarUrl(string avatarUrl) => AvatarUrl = avatarUrl;
        public void AddRating(int rating)
        {
            Rating = rating;
            RatingCount++;
        }
    }
}