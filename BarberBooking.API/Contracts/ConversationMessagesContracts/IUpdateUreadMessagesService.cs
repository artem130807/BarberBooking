using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Contracts.ConversationMessagesContracts
{
    public interface IUpdateUreadMessagesService
    {
        Task Update(Guid conversationId, Guid userId);
    }
}