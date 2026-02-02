using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace IdentityService.Events
{
    public class RejectedEvent:ApprovalEventBase
    {
        public Guid ResourceId { get; set; }
        public Guid UserId { get; set; }
        public bool IsApproved { get; set; } = false;
        public RejectedEvent(Guid resourceId, Guid userId)
        {
            ResourceId = resourceId;
            UserId = userId;
            IsApproved = false;
        }

        private RejectedEvent(){}
    }
}