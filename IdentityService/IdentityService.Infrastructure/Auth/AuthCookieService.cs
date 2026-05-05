using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Options;

namespace IdentityService.Infrastructure.Auth;

public interface IAuthCookieService
{
    void SetAuthCookie(HttpResponse response, string token);
    void RemoveAuthCookie(HttpResponse response);
    string? GetAuthCookie(HttpRequest request);
}

public class AuthCookieService : IAuthCookieService
{
    private const string CookieName = "tasty";

    private readonly JwtOptions _jwtOptions;

    public AuthCookieService(IOptions<JwtOptions> jwtOptions)
    {
        _jwtOptions = jwtOptions.Value;
    }

    public string? GetAuthCookie(HttpRequest request) => request.Cookies[CookieName];

    public void RemoveAuthCookie(HttpResponse response) => response.Cookies.Delete(CookieName);

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
