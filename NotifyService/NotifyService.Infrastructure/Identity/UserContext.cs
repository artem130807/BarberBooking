using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.AspNetCore.Http;
using NotifyService.Application.Contracts;

namespace NotifyService.Infrastructure.Identity;

public sealed class UserContext(IHttpContextAccessor httpContextAccessor) : IUserContext
{
    public Guid UserId
    {
        get
        {
            var http = httpContextAccessor.HttpContext;
            var userIdClaim = http?.User?.FindFirstValue("userId");

            if (string.IsNullOrEmpty(userIdClaim))
                userIdClaim = http?.User?.FindFirstValue(ClaimTypes.NameIdentifier);

            if (string.IsNullOrEmpty(userIdClaim))
                userIdClaim = http?.User?.FindFirstValue(JwtRegisteredClaimNames.Sub);

            return Guid.TryParse(userIdClaim, out var userId) ? userId : Guid.Empty;
        }
    }
}
