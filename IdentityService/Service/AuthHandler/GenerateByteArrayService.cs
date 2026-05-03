using System.Security.Cryptography;
using IdentityService.Contracts;

namespace IdentityService.Service.AuthHandler;

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
