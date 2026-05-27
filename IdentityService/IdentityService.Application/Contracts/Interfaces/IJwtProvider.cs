using IdentityService.Domain.Models;

namespace IdentityService.Application.Contracts;

public interface IJwtProvider
{
    Task<string> GenerateToken(Users users, string devices);
}
