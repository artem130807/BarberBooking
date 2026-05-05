using System.Security.Cryptography;
using IdentityService.Application.Contracts;

namespace IdentityService.Infrastructure.Auth;

public class GenerateByteArrayService : IGenerateByteArrayService
{
    public byte[] GenerateByteArray()
    {
        var randomBytes = new byte[64];
        using var rng = RandomNumberGenerator.Create();
        rng.GetBytes(randomBytes);
        return randomBytes;
    }
}
