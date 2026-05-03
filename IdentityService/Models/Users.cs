using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityService.Domain.ValueObjects;

namespace IdentityService.Models
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
        public ICollection<UserFcmToken> UserFcmTokens { get; set; }
        public ICollection<RefreshToken> RefreshTokens {get; set;}
        public Users()
        {
            UserFcmTokens = new List<UserFcmToken>();
            RefreshTokens = new List<RefreshToken>();
            Roles = new List<Roles>();
        }
    }
}