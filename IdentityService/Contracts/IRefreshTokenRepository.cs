using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityService.Models;

namespace BarberBooking.API.Contracts
{
    public interface IRefreshTokenRepository
    {
        Task Add(RefreshToken refreshToken);
        Task Delete(Guid Id);
        Task<RefreshToken> GetRefreshTokenByDevices(Guid userId, string devices);
        Task<RefreshToken> GetRefreshTokenByToken(string token);
        Task<RefreshToken> GetRefreshToken(Guid Id);
        Task<List<RefreshToken>> GetRefreshTokens(Guid userId);
        Task<List<RefreshToken>> GetRefreshRevokedTokens(Guid userId);
        Task SaveChangesAsync();
    }
}