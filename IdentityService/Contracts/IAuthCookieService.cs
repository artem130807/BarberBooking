using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Contracts
{
    public interface IAuthCookieService
    {
        void SetAuthCookie(HttpResponse response, string token);
        void RemoveAuthCookie(HttpResponse response);
        string? GetAuthCookie(HttpRequest request);
    }
}