using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.ConversationMessagesContracts;
using BarberBooking.API.Contracts.ConversationsContracts;
using BarberBooking.API.Dto.DtoConversation;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Conversations.Queries.Handlers
{
    public class GetConversationHandler : IRequestHandler<GetConversationQuery, Result<DtoConversationInfo>>
    {
        private readonly IConversationsRepository _conversationsRepository;
        private readonly IUserContext _userContext;
        private readonly IConversationMessagesRepository _conversationMessagesRepository;
        public GetConversationHandler(IConversationsRepository conversationsRepository, IUserContext userContext, IConversationMessagesRepository conversationMessagesRepository)
        {
            _conversationsRepository = conversationsRepository;
            _userContext = userContext;
            _conversationMessagesRepository = conversationMessagesRepository;
        }
        public async Task<Result<DtoConversationInfo>> Handle(GetConversationQuery query, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var conversation = await _conversationsRepository.GetConversation(query.Id);
            
            if(conversation == null)
                return Result.Failure<DtoConversationInfo>("Диалог не найден");
            if(!conversation.HasParticipant(userId))
                return Result.Failure<DtoConversationInfo>("Доступ запрещён");
            string userName = "";
            if(conversation.Participant1Id != userId)
                userName = conversation.Participant1.Name;
            if(conversation.Participant2Id != userId)
                userName = conversation.Participant2.Name;
            var unreadMessages = conversation.ConversationMessages.Where(m => m.ReceiverId == userId && m.IsRead == false).ToList();
            foreach(var message in unreadMessages)
            {
                message.UpdateIsRead();
            }
            await _conversationMessagesRepository.SaveChangesAsync();
            var result = new DtoConversationInfo
            {
                Id = conversation.Id,
                UserName = userName,
            };
            return Result.Success(result);
        }
    }
}