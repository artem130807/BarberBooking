using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;

namespace BarberBooking.API.Service
{
    public class UserContext : IUserContext
    {
        private readonly IHttpContextAccessor _httpContextAccessor;
        public UserContext(IHttpContextAccessor httpContextAccessor)
        {
            _httpContextAccessor = httpContextAccessor;
        }
        public Guid UserId {get
            {
             
            {
                
                var userIdClaim = _httpContextAccessor.HttpContext?
                    .User?.FindFirstValue("userId");
                    
                // 2. Если нет, пробуем стандартный
                if (string.IsNullOrEmpty(userIdClaim))
                {
                    userIdClaim = _httpContextAccessor.HttpContext?
                        .User?.FindFirstValue(ClaimTypes.NameIdentifier);
                }
                
                // 3. Если все еще null, пробуем JWT registered claim
                if (string.IsNullOrEmpty(userIdClaim))
                {
                    userIdClaim = _httpContextAccessor.HttpContext?
                        .User?.FindFirstValue(JwtRegisteredClaimNames.Sub);
                }
                
                return Guid.TryParse(userIdClaim, out var userId) ? userId : Guid.Empty;
            }
            }
        }
        public string UserCity
        {
            get
            {
               return _httpContextAccessor.HttpContext?.User?
                .FindFirstValue("userCity") ?? "";
            }
        }

        public bool IsAuthenticated => _httpContextAccessor.HttpContext?.User?.Identity?.IsAuthenticated ?? false;
    }
}