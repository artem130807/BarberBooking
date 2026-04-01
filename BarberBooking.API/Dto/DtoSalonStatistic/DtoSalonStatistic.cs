using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoSalonStatistic
{
    public class DtoSalonStatistic
    {
        public Guid SalonId {get; set;}
        public int CompletedAppointmentsCount {get; set;}
        public int CancelledAppointmentsCount {get; set;}
        public decimal Rating {get; set;}
        public int RatingCount {get; set;}
        public double SumPrice {get; set;}
    }
}