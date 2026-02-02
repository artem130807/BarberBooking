using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Org.BouncyCastle.Crypto.Engines;

namespace IdentityService.Events
{
    public class ApprovedEvent:ApprovalEventBase
    {
        public Guid ResourceId { get; set; }
        public Guid UserId { get; set; }
        public bool IsApproved { get; set; } 
        public DateTime RequestedAt { get; set; }

        public ApprovedEvent(Guid resourceId, Guid userId, bool isApproved)
        {
            ResourceId = resourceId;
            UserId = userId;
            IsApproved = isApproved;
            RequestedAt = DateTime.UtcNow;
        }
        private ApprovedEvent(){}
    }
}