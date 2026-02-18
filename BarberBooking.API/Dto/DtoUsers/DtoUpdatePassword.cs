using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoUsers
{
    public class DtoUpdatePassword
    {
        public string Email {get; set;}
        public string PasswordHash {get; set;}
    }
}