namespace IdentityService.Application.Contracts;

public interface IUserContext
{
    Guid UserId { get; }
    string UserCity { get; }
    bool IsAuthenticated { get; }
    IEnumerable<string> Roles { get; }
    bool IsInRole(string role);
}
