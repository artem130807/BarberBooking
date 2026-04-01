using System;

namespace BarberBooking.API.Dto.DtoMasterStatistic
{
    public class MasterStatsDto
    {
        public Guid MasterProfileId { get; set; }
        public int CompletedAppointmentsCount { get; set; }
        public int CancelledAppointmentsCount { get; set; }
        public int RatingCount { get; set; }
        public decimal Rating { get; set; }
        public double SumPrice { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
