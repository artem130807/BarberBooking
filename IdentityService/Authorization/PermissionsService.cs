using IdentityService.Contracts;
using IdentityService.Enums;

namespace IdentityService.Authorization;

public class PermissionsService : IPermissionService
{
    private readonly IUserRepository _userRepository;

    public PermissionsService(IUserRepository usersRepository)
    {
        _userRepository = usersRepository;
    }

    public Task<HashSet<PermissionsEnum>> GetPermissionsAsync(Guid userId)
    {
        return _userRepository.GetUserPermissions(userId);
    }
}
