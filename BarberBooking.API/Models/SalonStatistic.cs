using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Domain;
using BarberBooking.API.Domain.SalonStatisticDomain;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Models
{
    public class SalonStatistic:AggregateRoot
    {
        public Guid Id {get; private set;}
        public Guid SalonId {get; private set;}
        public Salons Salon {get; private set;}
        public int CompletedAppointmentsCount {get; private set;}
        public int CancelledAppointmentsCount {get; private set;}
        public double SumPrice {get; private set;}
        public decimal Rating {get; private set;}
        public int RatingCount {get; private set;}
        public DateTime CreatedAt {get; private set;}

        public static Result<SalonStatistic> Create(Guid salonId, int completedAppointmentsCount, int cancelledAppointmentsCount,  double sumPrice, int rating, int ratingCount)
        {
            var statistic = new SalonStatistic();
            statistic.ApplyChange(new CreateSalonStatisticEvent
            (Guid.NewGuid(), salonId, completedAppointmentsCount, 
            cancelledAppointmentsCount, sumPrice, rating,
            ratingCount));
            return statistic;
        }
        private void Apply(CreateSalonStatisticEvent @event)
        {
            Id = @event.AggregateId;
            SalonId = @event.SalonId;
            CompletedAppointmentsCount = @event.CompletedAppointmentsCount;
            CancelledAppointmentsCount = @event.CancelledAppointmentsCount;
            SumPrice = @event.SumPrice;
            Rating = @event.Rating;
            RatingCount = @event.RatingCount;
            CreatedAt = @event.CreatedAt;
        }
    }
}