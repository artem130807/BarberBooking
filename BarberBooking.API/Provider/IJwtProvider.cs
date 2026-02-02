using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;

namespace BarberBooking.API.Provider
{
    public interface IJwtProvider
    {
        Task<string> GenerateToken(Users users);
    }
}