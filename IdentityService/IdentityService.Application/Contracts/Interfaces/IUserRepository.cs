using IdentityService.Domain.Enums;
using IdentityService.Domain.Models;

namespace IdentityService.Application.Contracts;

public interface IUserRepository
{
    Task<Users> Register(Users users);
    Task<Users?> GetUserByPhone(string phone);
    Task<Users?> GetUserByEmail(string email);
    Task<HashSet<PermissionsEnum>> GetUserPermissions(Guid userId);
    Task UpdatePasswordHash(string email, string password);
    Task<string> UpdateCity(Guid id, string city);
    Task<Users?> GetUserById(Guid id);
    Task<Dictionary<Guid, string>> GetUsersByIds(IEnumerable<Guid> userIds);
}
