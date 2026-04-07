using System;

namespace BarberBooking.API.Dto.DtoMasterServices
{
    public class DtoMasterServiceInfo
    {
        public Guid Id { get; set; }
        public Guid MasterProfileId { get; set; }
        public Guid ServiceId { get; set; }
        public string? ServiceName { get; set; }
    }
}
