namespace IdentityService.Contracts;

public interface IAuthCookieService
{
    void SetAuthCookie(HttpResponse response, string token);
    void RemoveAuthCookie(HttpResponse response);
    string? GetAuthCookie(HttpRequest request);
}
