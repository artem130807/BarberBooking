using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Models
{
    public class Roles
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public ICollection<Users> Users { get; set; } = [];
        public ICollection<Permissions> Permissions { get; set; } = [];
    }
}