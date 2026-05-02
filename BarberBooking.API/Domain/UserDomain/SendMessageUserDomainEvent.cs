using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Domain.UserDomain
{
    public class UserSendMessage
    {
        public Guid UserId {get; private set;}
        public DateTime OccurredOn { get; init; } = DateTime.UtcNow;
        public string? CorrelationId { get; set; }
        public string Email {get; private set;}
        public string Content {get; private set;}

        public UserSendMessage(Guid userId, string email, string content)
        {
            UserId = userId;
            Email = email;
            Content = content;
            OccurredOn = DateTime.UtcNow;
            CorrelationId = Guid.NewGuid().ToString();
        }
    }
}