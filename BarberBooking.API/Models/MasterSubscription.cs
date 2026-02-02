using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Models
{
    public class MasterSubscription
    {
        public Guid Id { get; private set; }
        public Guid ClientId { get; private set; }
        public Guid MasterId { get; private set; }
        public DateTime SubscribedAt { get; private set; } = DateTime.UtcNow;
        public Users Client { get; private set; }
        public MasterProfile MasterProfile { get; private set; }
        private MasterSubscription(){}

        public static MasterSubscription Create(Guid clientId, Guid masterId)
        {
            var subscription = new MasterSubscription
            {
                Id = Guid.NewGuid(),
                ClientId = clientId,
                MasterId = masterId,
                SubscribedAt = DateTime.UtcNow
            };
            return subscription;
        }
    }
}