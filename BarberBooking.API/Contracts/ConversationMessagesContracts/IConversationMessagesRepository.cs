using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Filters;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts.ConversationMessagesContracts
{
    public interface IConversationMessagesRepository
    {
        Task Add(ConversationMessages conversationMessages);
        Task Delete(Guid Id);
        Task<ConversationMessages> GetMessage(Guid Id);
        Task<PagedResult<ConversationMessages>> GetMessages(Guid conversationId,PageParams pageParams);
        Task<int> GetUnreadMessagesByUser(Guid receiverId);
        Task<int> GetUnreadMessagesByConversation(Guid receiverId, Guid conversationId);
    }
}