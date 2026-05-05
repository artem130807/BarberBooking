using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using IdentityService.Application.Contracts;
using IdentityService.Domain.Models;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace IdentityService.Infrastructure.Auth;

public class JwtProvider : IJwtProvider
{
    private readonly IUserRolesRepository _userRolesRepository;
    private readonly JwtOptions _jwtOptions;

    public JwtProvider(IOptions<JwtOptions> jwtOptions, IUserRolesRepository userRolesRepository)
    {
        _jwtOptions = jwtOptions.Value;
        _userRolesRepository = userRolesRepository;
    }

    public async Task<string> GenerateToken(Users users, string devices)
    {
        var claims = new List<Claim>
        {
            new("userId", users.Id.ToString()),
            new("userCity", users.City ?? string.Empty),
            new("devices", devices ?? string.Empty),
            new(ClaimTypes.NameIdentifier, users.Id.ToString())
        };

        var rolesId = await _userRolesRepository.GetRolesIdByUserId(users.Id);
        foreach (var roleId in rolesId)
        {
            var roles = await _userRolesRepository.GetUserRolesAsync(roleId.RoleId);
            foreach (var role in roles)
                claims.Add(new Claim(ClaimTypes.Role, role.Name));
        }

        var signingCredentials = new SigningCredentials(
            new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtOptions.SecretKey)),
            SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            claims: claims,
            signingCredentials: signingCredentials,
            expires: DateTime.UtcNow.AddMinutes(_jwtOptions.ExpiresMinutes));

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
