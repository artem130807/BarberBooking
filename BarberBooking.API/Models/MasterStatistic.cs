using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Models
{
    public class MasterStatistic
    {
        public Guid Id {get; private set;}
        public Guid MasterProfileId {get; private set;}
        public MasterProfile MasterProfile {get; private set;}
        public decimal Rating {get; private set;}
        public int RatingCount {get; private set;}
        public int CompletedAppointmentsCount {get; private set;}
        public int CancelledAppointmentsCount {get; private set;}
        public double SumPrice {get; private set;}
        public DateTime CreatedAt {get; private set;}

        public static Result<MasterStatistic> Create(
            Guid masterProfileId,
            int completedAppointmentsCount,
            int cancelledAppointmentsCount,
            double sumPrice,
            decimal rating,
            int ratingCount,
            DateTime createdAt)
        {
            var statistic = new MasterStatistic
            {
                Id = Guid.NewGuid(),
                MasterProfileId = masterProfileId,
                Rating = rating,
                RatingCount = ratingCount,
                CompletedAppointmentsCount = completedAppointmentsCount,
                CancelledAppointmentsCount = cancelledAppointmentsCount,
                SumPrice = sumPrice,
                CreatedAt = createdAt
            };
            return statistic;
        }

    }
}