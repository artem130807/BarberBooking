using IdentityService.Contracts;

namespace IdentityService.Service.AuthHandler;

public class PasswordHasher : IPasswordHasher
{
    public string Generate(string password)
    {
        return BCrypt.Net.BCrypt.HashPassword(password);
    }

    public bool Verify(string password, string passwordHash)
    {
        return BCrypt.Net.BCrypt.Verify(password, passwordHash);
    }
}
