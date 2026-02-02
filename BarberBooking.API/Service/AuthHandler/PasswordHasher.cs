using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;

namespace BarberBooking.API.Service
{
    public class PasswordHasher : IPasswordHasher
    {
        public string Generate(string Password) => BCrypt.Net.BCrypt.EnhancedHashPassword(Password);
        public bool Verify(string Password, string PasswordHash) => BCrypt.Net.BCrypt.EnhancedVerify(Password, PasswordHash);
       
    }
}