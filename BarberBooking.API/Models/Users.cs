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
        public ICollection<UserFcmToken> UserFcmTokens { get; set; }
        public ICollection<RefreshToken> RefreshTokens {get; set;}
        public ICollection<Conversations> ConversationsAsParticipant1 { get; set; }
        public ICollection<Conversations> ConversationsAsParticipant2 { get; set; }
        public Users()
        {
            Messages = new List<Messages>();
            SalonsAdmins = new List<SalonsAdmin>();
            UserFcmTokens = new List<UserFcmToken>();
            RefreshTokens = new List<RefreshToken>();
            ConversationsAsParticipant1 = new List<Conversations>();
            ConversationsAsParticipant2 = new List<Conversations>();
        }
    }
}
