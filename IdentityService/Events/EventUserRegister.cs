using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityService.DtoModels;
using IdentityService.Models;

namespace IdentityService.Events
{
    public record EventUserRegister(Guid EventId, Guid UserId, List<int> RoleId, string Name, string Email);
}