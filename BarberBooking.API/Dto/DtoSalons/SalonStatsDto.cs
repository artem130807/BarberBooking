using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoSalons
{
    public class SalonStatsDto
    {
        public Guid SalonId {get; set;}
        public int CompletedAppointmentsCount {get; set;}
        public int CancelledAppointmentsCount {get; set;}
        public int RatingCount {get; set;}
        public decimal Rating {get; set;}
        public decimal SumPrice {get; set;}
        public DateTime CreatedAt {get;  set;}
    }
}