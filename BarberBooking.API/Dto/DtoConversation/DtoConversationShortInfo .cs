using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoConversation
{
    public class DtoConversationShortInfo 
    {
        public Guid Id {get; set;}
        public string UserName {get; set;}
        public int CountUreadMessages {get; set;}
        public string? LastMessageContent {get; set;}
        public DateTime? LastMessageAt { get; set; }
    }
} 