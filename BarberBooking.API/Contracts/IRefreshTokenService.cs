using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Contracts
{
    public interface IRefreshTokenService
    {
        Task<byte[]> CreateToken(Guid userId, string devices);
        Task RevokedToken(Guid userId, string devices);
    }
}