using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoUsers
{
    public class DtoCreateUser
    {
        public string Name { get; set; }
        public DtoPhone Phone { get; set; }
        public string Email {get ; set;}
        public string PasswordHash { get; set; }
        public string City { get; set; }
    }
}