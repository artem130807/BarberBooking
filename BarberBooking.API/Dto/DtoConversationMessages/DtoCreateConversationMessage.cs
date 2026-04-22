using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoConversationMessages
{
    public class DtoCreateConversationMessage
    {
        public Guid ConversationId {get; set;}
        public string Content {get ; set;}
    }
}