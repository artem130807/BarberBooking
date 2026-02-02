using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Models
{
    public class Permissions
    {
        public int Id { get; set; }
        public string Name { get; set; } 
        public ICollection<Roles> Roles{ get; set; }
    }
}