using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Models
{
    public class UserRoles
    {
        public Guid UserId { get; set; }
        public int RoleId { get; set; }
    }
}