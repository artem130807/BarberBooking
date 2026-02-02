using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityService.Models;

namespace IdentityService.Contracts
{
    public interface IPermissionsRepository
    {
        Task<List<Permissions>> GetPermissionsById(List<int> permissionId);
    }
}