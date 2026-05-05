using IdentityService.Domain.Enums;

namespace IdentityService.Application.Contracts;

public interface IPermissionService
{
    Task<HashSet<PermissionsEnum>> GetPermissionsAsync(Guid userId);
}
