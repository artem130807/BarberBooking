using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace IdentityService.Provider
{
    public class JwtOptions
    {
        public string SecretKey { get; set; }
        public int ExpiresMinutes { get; set; }
    }
}