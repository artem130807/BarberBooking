using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using IdentityService.Contracts;
using IdentityService.Models;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace IdentityService.Provider
{
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
                new Claim("userId", users.Id.ToString()),
                new Claim("userCity", users.City.ToString()),
                new Claim("devices", devices.ToString()),
                new Claim(ClaimTypes.NameIdentifier, users.Id.ToString())
            };
            
            var rolesId = await _userRolesRepository.GetRolesIdByUserId(users.Id);
            foreach(var roleId in rolesId)
            {
                var roles = await _userRolesRepository.GetUserRolesAsync(roleId.RoleId);
                foreach(var role in roles)
                {
                    claims.Add(new Claim(ClaimTypes.Role, role.Name));
                }
            }
             
            var signingCredentials = new SigningCredentials(new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwtOptions.SecretKey)), SecurityAlgorithms.HmacSha256);
            var token = new JwtSecurityToken(
                claims: claims,
                signingCredentials: signingCredentials,
                expires: DateTime.UtcNow.AddMinutes(_jwtOptions.ExpiresMinutes)
            );
            var tokenvalue = new JwtSecurityTokenHandler().WriteToken(token);
            return tokenvalue;
        }
    }
}