using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Models
{
    public class SalonStatistic
    {
        public Guid Id {get; private set;}
        public Guid SalonId {get; private set;}
        public Salons Salon {get; private set;}
        public int CompletedAppointmentsCount {get; private set;}
        public int CancelledAppointmentsCount {get; private set;}
        public decimal Rating {get; private set;}
        public int RatingCount {get; private set;}
        public DateTime CreatedAt {get; private set;}

        public static Result<SalonStatistic> Create(Guid salonId, int completedAppointmentsCount, int cancelledAppointmentsCount,  int rating, int ratingCount)
        {
            var statistic = new SalonStatistic
            {
                Id = Guid.NewGuid(),
                SalonId = salonId,
                CompletedAppointmentsCount = completedAppointmentsCount,
                CancelledAppointmentsCount = cancelledAppointmentsCount,
                Rating = rating,
                RatingCount = ratingCount,
                CreatedAt = DateTime.UtcNow
            };
            return Result.Success(statistic);
        }
    }
}