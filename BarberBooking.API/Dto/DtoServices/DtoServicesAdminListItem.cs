using System;
using BarberBooking.API.Dto.DtoVo;

namespace BarberBooking.API.Dto.DtoServices
{
  
    public class DtoServicesAdminListItem
    {
        public Guid Id { get; private set; }
        public Guid SalonId { get; private set; }
        public string Name { get; private set; }
        public string? Description { get; private set; }
        public int DurationMinutes { get; private set; }
        public DtoPrice Price { get; private set; }
        public string? PhotoUrl { get; private set; }
        public bool IsActive { get; private set; }
        public DateTime CreatedAt { get; private set; }
    }
}
