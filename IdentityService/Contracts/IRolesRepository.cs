using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityService.Models;

namespace IdentityService.Contracts
{
    public interface IRolesRepository
    {
        Task<List<UserRoles>> GetRolesIdByUserId(Guid userId);
    }
}