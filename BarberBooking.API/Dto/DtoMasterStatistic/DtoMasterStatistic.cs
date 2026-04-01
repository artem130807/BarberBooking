using System;

namespace BarberBooking.API.Dto.DtoMasterStatistic
{
    public class DtoMasterStatistic
    {
        public Guid MasterProfileId { get; set; }
        public int CompletedAppointmentsCount { get; set; }
        public int CancelledAppointmentsCount { get; set; }
        public decimal Rating { get; set; }
        public int RatingCount { get; set; }
        public double SumPrice { get; set; }
    }
}
