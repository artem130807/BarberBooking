using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace IdentityService.Application.Contracts.Base
{
    public abstract class IntegrationEvent
    {
        public Guid EventId {get; init;} = Guid.NewGuid();
        public string EventType {get; protected set;}
        public DateTime OccuredAt {get; private set;} = DateTime.UtcNow;
    }
}