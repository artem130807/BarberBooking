using System;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Dto.DtoMasterProfile;
using BarberBooking.API.Dto.DtoSalons;

namespace BarberBooking.API.Dto.DtoReview
{
    public class DtoReviewAdminListItem
    {
        public Guid Id { get; private set; }
        public Guid AppointmentId { get; private set; }
        public Guid ClientId { get; private set; }
        public Guid SalonId { get; private set; }

        public string ClientName { get; private set; }
        public int SalonRating { get; private set; }
        public int? MasterRating { get; private set; }
        public string? Comment { get; private set; }
        public DateTime CreatedAt { get; private set; }

        public DtoSalonNavigation dtoSalonNavigation { get; private set; }
        public DtoMasterProfileNavigation masterProfileNavigation { get; private set; }
        public DtoAppointmentNavigation dtoAppointmentNavigation { get; private set; }
    }
}
