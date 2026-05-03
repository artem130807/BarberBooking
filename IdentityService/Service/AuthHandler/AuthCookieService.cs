using IdentityService.Contracts;
using IdentityService.Provider;
using Microsoft.Extensions.Options;

namespace IdentityService.Service.AuthHandler;

public class AuthCookieService : IAuthCookieService
{
    private readonly JwtOptions _jwtOptions;
    private const string CookieName = "tasty";

    public AuthCookieService(IOptions<JwtOptions> jwtOptions)
    {
        _jwtOptions = jwtOptions.Value;
    }

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
            Expires = DateTime.UtcNow.AddMinutes(_jwtOptions.ExpiresMinutes),
            Path = "/",
            Domain = null
        };
        response.Cookies.Append(CookieName, token, cookieOptions);
    }
}
