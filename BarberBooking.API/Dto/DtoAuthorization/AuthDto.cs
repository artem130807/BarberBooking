using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto
{
    public class AuthDto
    {
        public string AccessToken { get; set; }
        public byte[]? RefreshToken {get; set;}
        public string Message { get; set; }
        public int RoleInterface {get; set;}
    }
}