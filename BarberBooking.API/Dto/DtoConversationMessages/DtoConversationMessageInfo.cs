using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoConversationMessages
{
    public class DtoConversationMessageInfo
    {
        public Guid Id {get; set;}
        public string SenderName {get; set;}
        public string Content {get; set;}
        public bool IsRead {get; set;}
        public DateTime SendTime {get; set;}
    }
}