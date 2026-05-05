using IdentityService.Domain.Models;

namespace IdentityService.Application.Contracts;

public interface IPermissionsRepository
{
    Task<List<Permissions>> GetPermissionsById(List<int> permissionId);
}
