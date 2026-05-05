using CSharpFunctionalExtensions;

namespace IdentityService.Domain.Models;

public class UserRoles
{
    public Guid UserId { get; set; }
    public int RoleId { get; set; }

    public static Result<UserRoles> Create(Guid userId, int roleId)
    {
        return Result.Success(new UserRoles { UserId = userId, RoleId = roleId });
    }
}
