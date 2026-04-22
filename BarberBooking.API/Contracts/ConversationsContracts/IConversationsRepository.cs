using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.ConversationFilter;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts.ConversationsContracts
{
    public interface IConversationsRepository
    {
        Task Add(Conversations conversations);
        Task Delete(Guid Id);
        Task<Conversations> GetConversation(Guid Id);
        Task<PagedResult<Conversations>> GetPagedResultAsync(Guid userId, PageParams pageParams);
        Task<PagedResult<Conversations>> GetConversationBySearch(Guid userId, SearchConversationFilter filter, PageParams pageParams);
    }
}