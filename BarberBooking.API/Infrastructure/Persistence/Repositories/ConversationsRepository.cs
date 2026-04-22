using BarberBooking.API.Contracts.ConversationsContracts;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.ConversationFilter;
using BarberBooking.API.Models;
using Microsoft.AspNetCore.DataProtection.AuthenticatedEncryption;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Infrastructure.Persistence.Repositories
{
    public class ConversationsRepository : IConversationsRepository
    {
        private readonly BarberBookingDbContext _context;
        public ConversationsRepository(BarberBookingDbContext context)
        {
            _context = context;
        }
        public async Task Add(Conversations conversations)
        {
            _context.Conversations.Add(conversations);
        }

        public async Task Delete(Guid Id)
        {
            await _context.Conversations.Where(x => x.Id == Id).ExecuteDeleteAsync();
        }

        public async Task<PagedResult<Conversations>> GetConversationBySearch(Guid userId,  SearchConversationFilter filter, PageParams pageParams)
        {
            var conversations = _context.Conversations
            .Include(x => x.Participant1)
            .Include(x => x.Participant2)
            .Include(x => x.ConversationMessages)
            .Where(x =>  x.Participant1Id == userId || x.Participant2Id == userId);
            if (!string.IsNullOrWhiteSpace(filter.Name))
            {
                conversations = conversations
                .Where(x => x.Participant1Id != userId && x.Participant1.Name.StartsWith(filter.Name) 
                || x.Participant2Id != userId && x.Participant2.Name.StartsWith(filter.Name));
            }
            var result = conversations.OrderByDescending(x => x.LastMessageAt).ToList();
            return new PagedResult<Conversations>(result, result.Count);
        }

        public async Task<Conversations> GetConversation(Guid Id)
        {
           return await _context.Conversations.FirstOrDefaultAsync(x => x.Id == Id);
        }
        public async Task<PagedResult<Conversations>> GetPagedResultAsync(Guid userId, PageParams pageParams)
        {
            return await _context.Conversations
            .Include(x => x.Participant1)
            .Include(x => x.Participant2)
            .Include(x => x.ConversationMessages)
            .Where(x => x.Participant1Id == userId || x.Participant2Id == userId)
            .OrderByDescending(x => x.LastMessageAt)
            .ToPagedAsync(pageParams);
        }
    }
}
