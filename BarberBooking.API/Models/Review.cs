using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Models
{
    public class Review
    {
        public Guid Id { get; private set;}
        public Guid AppointmentId { get; private set; }
        public Guid ClientId { get; private set; }
        public Guid SalonId { get; private set; }
        public Guid? MasterProfileId { get; private set; }
        public int SalonRating { get; private set; } 
        public int? MasterRating {get; private set;}
        public string? Comment { get; private set; }
        public DateTime CreatedAt { get; private set; } = DateTime.UtcNow;
        public Appointments Appointment { get; private set; }
        public Users Client { get; private set; }
        public Salons Salon { get; private set; }
        public MasterProfile? MasterProfile { get; private set; }
        private Review(){}
        public static Review Create(Guid appointmentId, Guid salonId, Guid? masterProfileId, int salonRating, int? masterRating, string? comment)
        {
            var review = new Review
            {
                Id = Guid.NewGuid(),
                AppointmentId = appointmentId,
                SalonId = salonId,
                MasterProfileId = masterProfileId,
                SalonRating = salonRating,
                MasterRating = masterRating,
                Comment = comment
            };
            return review;
        }
        public void UpdateComment(string comment) => Comment = comment;
        
    }
}