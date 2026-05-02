using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.ConversationMessagesContracts;
using Confluent.Kafka;

namespace BarberBooking.API.Service.UpdateService
{
    public class UpdateUreadMessagesService : IUpdateUreadMessagesService
    {
        private readonly IConversationMessagesRepository _conversationMessagesRepository;
        public UpdateUreadMessagesService(IConversationMessagesRepository conversationMessagesRepository)
        {
            _conversationMessagesRepository = conversationMessagesRepository;
        }
        public async Task Update(Guid conversationId, Guid userId)
        {
            var messages = await _conversationMessagesRepository.GetUnreadMessagesByConversation(userId , conversationId);
            if(messages.Count != 0)
            {
                foreach(var message in messages)
                {
                    message.UpdateIsRead();
                }
            }
            await _conversationMessagesRepository.SaveChangesAsync();
        }
    }
}