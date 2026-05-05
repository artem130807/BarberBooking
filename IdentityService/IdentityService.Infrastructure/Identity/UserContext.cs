using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using IdentityService.Application.Contracts;
using Microsoft.AspNetCore.Http;

namespace IdentityService.Infrastructure.Identity;

public class UserContext : IUserContext
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public UserContext(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public Guid UserId
    {
        get
        {
            var http = _httpContextAccessor.HttpContext;
            var userIdClaim = http?.User?.FindFirstValue("userId")
                ?? http?.User?.FindFirstValue(ClaimTypes.NameIdentifier)
                ?? http?.User?.FindFirstValue(JwtRegisteredClaimNames.Sub);
            return Guid.TryParse(userIdClaim, out var userId) ? userId : Guid.Empty;
        }
    }

    public string UserCity =>
        _httpContextAccessor.HttpContext?.User?.FindFirstValue("userCity") ?? string.Empty;

    public IEnumerable<string> Roles =>
        _httpContextAccessor.HttpContext?.User?.FindAll(ClaimTypes.Role).Select(c => c.Value) ?? [];

    public bool IsInRole(string role) => Roles.Contains(role);

    public bool IsAuthenticated =>
        _httpContextAccessor.HttpContext?.User?.Identity?.IsAuthenticated ?? false;
}
