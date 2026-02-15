using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Domain.ValueObjects;

namespace BarberBooking.API.Dto.DtoUsers
{
    public class DtoLoginUser
    {
        public string Email {get; set;}
        public string  PasswordHash {get; set;}
    }
}