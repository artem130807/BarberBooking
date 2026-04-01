using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using BarberBooking.API.Domain;
using BarberBooking.API.Domain.MasterDomain;
using BarberBooking.API.Domain.ValueObjects;

namespace BarberBooking.API.Models
{
    public class MasterProfile:AggregateRoot
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
        public ICollection<MasterStatistic> MasterStatistics {get; private set;}
        public DateTime CreatedAt {get; private set;} = DateTime.UtcNow;

        private MasterProfile()
        {
            TimeSlots = new List<MasterTimeSlot>();
            Appointments = new List<Appointments>();
            Subscriptions = new List<MasterSubscription>();
            Reviews = new List<Review>();
            WeeklyTemplates = new List<WeeklyTemplate>();
            MasterStatistics = new List<MasterStatistic>();
        }
        public static MasterProfile Create(Guid userId, Guid salonId, string? bio, string? specialization, string? avatarUrl)
        {
            var master = new MasterProfile();
            master.ApplyChange(new MasterCreatedEvent(Guid.NewGuid() ,userId, salonId, bio, specialization, avatarUrl));
            return master;
        }
        public void UpdateBio(string bio) => Bio = bio;
        public void UpdateSpecialization(string specialization) => Specialization = specialization;
        public void UpdateAvatarUrl(string avatarUrl) => AvatarUrl = avatarUrl;
        public void AddRating(decimal rating, int ratingCount)
        {
            ApplyChange(new MasterAddRatingEvent(Id, rating, ratingCount));
        }
        public void RollBackRating(decimal previousRating, int previousRatingCount)
        {
            ApplyChange(new MasterRollBackRatingEvent(Id, previousRating, previousRatingCount));
        }
        private void Apply(MasterCreatedEvent @event)
        {
            Id = @event.AggregateId;
            UserId = @event.UserId;
            SalonId = @event.SalonId;
            Bio = @event.Bio;
            Specialization = @event.Specialization;
            AvatarUrl = @event.AvatarUrl;
            Rating = 0;
            RatingCount = 0;
            CreatedAt = DateTime.UtcNow;

            TimeSlots = new List<MasterTimeSlot>();
            Appointments = new List<Appointments>();
            Subscriptions = new List<MasterSubscription>();
            Reviews = new List<Review>();
            WeeklyTemplates = new List<WeeklyTemplate>();
            MasterStatistics = new List<MasterStatistic>();
        }
        private void Apply(MasterAddRatingEvent @event)
        {
            Rating = @event.Rating;
            RatingCount = @event.RatingCount;
        }
        private void Apply(MasterRollBackRatingEvent @event)
        {
            Rating = @event.PreviousRating;
            RatingCount = @event.PreviousRatingCount;
        }
    }
}