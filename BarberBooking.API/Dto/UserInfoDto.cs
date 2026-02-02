using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto
{
    public class UserInfoDto
    {
        public Guid Id { get; set; } 
        public string Name {get; set;}
        public string Email { get; set; }     
        public string City { get; set; }
    }
}