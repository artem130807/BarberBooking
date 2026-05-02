using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Models
{
    public class EmailVerification
    {
        public Guid Id {get; set;}
        public string Email { get; set; } = string.Empty;
        public string Code { get; set; } = string.Empty;
        public DateTime CratedDate { get; set; } = DateTime.UtcNow;
        public DateTime ExpiresAt { get; set; } 
        public DateTime LastSentAt {get; set;}
        public bool IsUsed { get; set; } = false;
    }
}