using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Enums;
using BarberBooking.API.Provider;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.DependencyInjection;

namespace BarberBooking.API.Authorization
{
    public class PermissionHandler : AuthorizationHandler<PermissionRequirement>
    {
        private const string PermissionsItemPrefix = "__BarberBooking.Permissions__";

        private readonly IServiceScopeFactory _scope;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public PermissionHandler(IServiceScopeFactory scope, IHttpContextAccessor httpContextAccessor)
        {
            _scope = scope;
            _httpContextAccessor = httpContextAccessor;
        }

        protected override async Task HandleRequirementAsync(AuthorizationHandlerContext context, PermissionRequirement requirement)
        {
            var userId = context.User.Claims.FirstOrDefault(x => x.Type == CustomClaims.UserId);
            if (userId is null || !Guid.TryParse(userId.Value, out var id))
            {
                return;
            }

            HashSet<PermissionsEnum> permissions;
            var httpContext = _httpContextAccessor.HttpContext;
            var cacheKey = (object)$"{PermissionsItemPrefix}{id:N}";
            if (httpContext != null &&
                httpContext.Items.TryGetValue(cacheKey, out var cached) &&
                cached is HashSet<PermissionsEnum> stored)
            {
                permissions = stored;
            }
            else
            {
                using var scope = _scope.CreateScope();
                var permissionsService = scope.ServiceProvider.GetRequiredService<IPermissionService>();
                permissions = await permissionsService.GetPermissionsAsync(id);
                if (httpContext != null)
                    httpContext.Items[cacheKey] = permissions;
            }

            if (permissions.Intersect(requirement.Permissions).Any())
                context.Succeed(requirement);
        }
    }
}