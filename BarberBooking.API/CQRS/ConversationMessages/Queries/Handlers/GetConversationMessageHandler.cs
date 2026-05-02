using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.ConversationMessagesContracts;
using BarberBooking.API.Dto.DtoConversationMessages;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.ConversationMessages.Queries.Handlers
{
    public class GetConversationMessageHandler : IRequestHandler<GetConversationMessageQuery, Result<DtoConversationMessageInfo>>
    {
        private readonly IConversationMessagesRepository _conversationMessagesRepository;
        public GetConversationMessageHandler(IConversationMessagesRepository conversationMessagesRepository)
        {
            _conversationMessagesRepository = conversationMessagesRepository;
        }
        public async Task<Result<DtoConversationMessageInfo>> Handle(GetConversationMessageQuery query, CancellationToken cancellationToken)
        {
            var message = await _conversationMessagesRepository.GetMessage(query.Id);
            if(message == null)
                return Result.Failure<DtoConversationMessageInfo>("Не удалось получить сообщение");
            var result = new DtoConversationMessageInfo
            {
                Id = message.Id,
                SenderName = message.Sender.Name,
                Content = message.Content,
                IsRead = message.IsRead,
                SendTime = message.CreatedAt
            };
            return Result.Success(result);
        }
    }
}