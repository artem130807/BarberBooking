using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Domain.MasterDomain
{
    public class MasterCreatedEvent:DomainEvent
    {
        public Guid UserId { get; set; }
        public Guid SalonId {get;  set;}
        public string? Bio { get;  set; }
        public string? Specialization { get;  set; }
        public string? AvatarUrl { get; set; }
        private MasterCreatedEvent(){}
        public MasterCreatedEvent(Guid masterId, Guid userId, Guid salonId, string? bio, string? specialization, string? avatarUrl)
        {
            AggregateId = masterId;
            UserId = userId;
            SalonId = salonId;
            Bio = bio;
            Specialization = specialization;
            AvatarUrl = avatarUrl;
        }
    }
}