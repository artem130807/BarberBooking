using System;
using BarberBooking.API.Dto;
using BarberBooking.API.Dto.DtoVo;

namespace BarberBooking.API.Dto.DtoSalons
{
   
    public class DtoSalonAdminStats
    {
        public Guid Id { get; private set; }
        public string Name { get; private set; }
        public string? Description { get; private set; }
        public DtoAddress Address { get; private set; }
        public DtoPhone? Phone { get; private set; }
        public string? MainPhotoUrl { get; private set; }
        public bool IsActive { get; private set; }
        public decimal Rating { get; private set; }
        public int RatingCount { get; private set; }
        public DateTime CreatedAt { get; private set; }

        public int MastersCount { get; private set; }
        public int ServicesCount { get; private set; }
        public int AppointmentsCount { get; private set; }
        public int ReviewsCount { get; private set; }
    }
}
