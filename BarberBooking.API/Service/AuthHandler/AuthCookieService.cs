using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;

namespace BarberBooking.API.Service.AuthHandler
{
    public class AuthCookieService : IAuthCookieService
    {
        private const string CookieName = "tasty";
        public string? GetAuthCookie(HttpRequest request)
        {
            return request.Cookies[CookieName];
        }

        public void RemoveAuthCookie(HttpResponse response)
        {
            response.Cookies.Delete(CookieName);
        }

        public void SetAuthCookie(HttpResponse response, string token)
        {
            var cookieOptions = new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                Expires = DateTime.UtcNow.AddHours(12),
                Path = "/", 
                Domain = null 
            }; 
            response.Cookies.Append(CookieName, token, cookieOptions);
        }
    }
}