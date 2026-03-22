using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Dto.DtoMessages
{
    public class DtoMessagesShortInfo
    {
        public Guid Id {get; private set;}
        public string Content {get; private set;}
        public DateTime CreatedAt {get; private set;}
    }
}