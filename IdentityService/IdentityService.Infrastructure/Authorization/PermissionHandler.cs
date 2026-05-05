using IdentityService.Application.Contracts;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.DependencyInjection;

namespace IdentityService.Infrastructure.Authorization;

public class PermissionHandler : AuthorizationHandler<PermissionRequirement>
{
    private const string UserIdClaim = "userId";

    private readonly IServiceScopeFactory _scope;

    public PermissionHandler(IServiceScopeFactory scope)
    {
        _scope = scope;
    }

    protected override async Task HandleRequirementAsync(AuthorizationHandlerContext context, PermissionRequirement requirement)
    {
        var userId = context.User.Claims.FirstOrDefault(x => x.Type == UserIdClaim);
        if (userId is null || !Guid.TryParse(userId.Value, out var id))
            return;

        using var scope = _scope.CreateScope();
        var permissionsService = scope.ServiceProvider.GetRequiredService<IPermissionService>();
        var permissions = await permissionsService.GetPermissionsAsync(id);
        if (permissions.Intersect(requirement.Permissions).Any())
            context.Succeed(requirement);
    }
}
