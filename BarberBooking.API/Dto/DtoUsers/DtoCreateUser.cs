using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoUsers
{
    public class DtoCreateUser
    {
        [Required]
        public string Name { get; set; }
        [Required]
        public DtoPhone Phone { get; set; }
        [Required]
        public string Email {get ; set;}
        [Required]
        public string PasswordHash { get; set; }
        [Required]
        public string City { get; set; }
        [Required]
        public string Devices {get; set;}
    }
}