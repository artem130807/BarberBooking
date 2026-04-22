using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.ConversationMessagesContracts;
using BarberBooking.API.Filters;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Infrastructure.Persistence.Repositories
{
    public class ConversationMessagesRepository:IConversationMessagesRepository
    {
        private readonly BarberBookingDbContext _context;
        public ConversationMessagesRepository(BarberBookingDbContext context)
        {
            _context = context;
        }

        public async Task Add(ConversationMessages conversationMessages)
        {
            _context.ConversationMessages.Add(conversationMessages);
        }

        public async Task Delete(Guid Id)
        {
            await _context.ConversationMessages.Where(x => x.Id == Id).ExecuteDeleteAsync();
        }

        public async Task<ConversationMessages> GetMessage(Guid Id)
        {
            return await _context.ConversationMessages.FirstOrDefaultAsync(x => x.Id == Id);
        }

        public async Task<PagedResult<ConversationMessages>> GetMessages(Guid conversationId, PageParams pageParams)
        {
            return await _context.ConversationMessages.Where(x => x.ConversationsId == conversationId).ToPagedAsync(pageParams);
        }

        public async Task<int> GetUnreadMessagesByConversation(Guid receiverId, Guid conversationId)
        {
            return await _context.ConversationMessages.Where(x => x.ReceiverId == receiverId && x.ConversationsId == conversationId).CountAsync();
        }

        public async Task<int> GetUnreadMessagesByUser(Guid receiverId)
        {
            return await _context.ConversationMessages.Where(x => x.ReceiverId == receiverId).CountAsync();
        }
    }
}