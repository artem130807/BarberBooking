using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Domain.ValueObjects;

namespace BarberBooking.API.Models
{
    public class Users
    {
        public Guid Id { get; set; }
        public string Name { get; set; }
        public PhoneNumber Phone { get; set; }
        public string Email {get ; set;}
        public string PasswordHash { get; set; }
        public string City { get; set; }
        public ICollection<Roles> Roles { get; set; }
        public ICollection<Messages> Messages {get; set;}
        public ICollection<SalonsAdmin> SalonsAdmins {get; set;}

        public Users()
        {
            Messages = new List<Messages>();
            SalonsAdmins = new List<SalonsAdmin>();
        }
    }
}