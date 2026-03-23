using System;

namespace BarberBooking.API.Dto.DtoMasterProfile
{
    public class DtoCreateMasterProfile
    {
        public string EmailUser { get; set; } = string.Empty;
        public Guid SalonId { get; set; }
        public string? Bio { get; set; }
        public string? Specialization { get; set; }
        public string? AvatarUrl { get; set; }
    }
}
