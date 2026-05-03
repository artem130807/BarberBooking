using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityService.Models;
namespace IdentityService.Provider
{
    public interface IJwtProvider
    {
        Task<string> GenerateToken(Users users, string devices);
    }
}