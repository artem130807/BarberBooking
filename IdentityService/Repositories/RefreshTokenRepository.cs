using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using IdentityService.Contracts;
using IdentityService.Models;
using Microsoft.EntityFrameworkCore;

namespace IdentityService.Repositories
{
    public class RefreshTokenRepository:IRefreshTokenRepository
    {
        private readonly IdentityServiceDbContext _context;

        public RefreshTokenRepository(IdentityServiceDbContext context)
        {
            _context = context;
        }

        public async Task Add(RefreshToken refreshToken)
        {
            _context.RefreshTokens.Add(refreshToken);
        }

        public async Task Delete(Guid Id)
        {
            await _context.RefreshTokens.Where(x => x.Id == Id).ExecuteDeleteAsync();
        }

        public async Task<RefreshToken> GetRefreshToken(Guid Id)
        {
            return await _context.RefreshTokens.FindAsync(Id);
        }

        public async Task<List<RefreshToken>> GetRefreshTokens(Guid userId)
        {
            return await _context.RefreshTokens.Where(x => x.UserId == userId && x.IsRevoked == false).ToListAsync();
        }

        public async Task<List<RefreshToken>> GetRefreshRevokedTokens(Guid userId)
        {
            return await _context.RefreshTokens.Where(x => x.UserId == userId && x.IsRevoked == true).ToListAsync();
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }

        public async Task<RefreshToken> GetRefreshTokenByDevices(Guid userId ,string devices)
        {
            return await _context.RefreshTokens.FirstOrDefaultAsync(x => 
            x.UserId == userId &&  
            x.Devices == devices && 
            x.IsRevoked == false);
        }

        public async Task<RefreshToken> GetRefreshTokenByToken(string token)
        {
            return await _context.RefreshTokens.FirstOrDefaultAsync(x => x.TokenHash == token);
        }
    }
}