using IdentityService.Application.Contracts;
using IdentityService.Domain.Enums;

namespace IdentityService.Infrastructure.Authorization;

public class PermissionsService : IPermissionService
{
    private readonly IUserRepository _userRepository;

    public PermissionsService(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }

    public Task<HashSet<PermissionsEnum>> GetPermissionsAsync(Guid userId)
    {
        return _userRepository.GetUserPermissions(userId);
    }
}
