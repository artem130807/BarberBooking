using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace IdentityService.Events
{
    public record EventUserLogin(Guid EventId, Guid UserId, List<int> RoleId, string Name, string Email);
}