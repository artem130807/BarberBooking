using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace IdentityService.Events
{
    public abstract class ApprovalEventBase
    {
        public Guid CorrelationId { get; } = Guid.NewGuid();
        public DateTime ApprovedAt { get; } = DateTime.UtcNow;
    }
}