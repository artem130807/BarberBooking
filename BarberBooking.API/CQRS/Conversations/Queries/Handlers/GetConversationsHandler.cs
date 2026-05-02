using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.ConversationMessagesContracts;
using BarberBooking.API.Contracts.ConversationsContracts;
using BarberBooking.API.Dto.DtoConversation;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Conversations.Queries.Handlers
{
    public class GetConversationsHandler : IRequestHandler<GetConversationsQuery, Result<PagedResult<DtoConversationShortInfo>>>
    {
        private readonly IConversationsRepository _conversationsRepository;
        private readonly IUserRepository _userRepository;
        private readonly IUserContext _userContext;
        private readonly IConversationMessagesRepository _conversationMessagesRepository;
        public GetConversationsHandler(IConversationsRepository conversationsRepository, IUserRepository userRepository, IUserContext userContext, IConversationMessagesRepository conversationMessagesRepository)
        {
            _conversationsRepository = conversationsRepository;
            _userRepository = userRepository;
            _userContext = userContext;
            _conversationMessagesRepository = conversationMessagesRepository;
        }
        public async Task<Result<PagedResult<DtoConversationShortInfo>>> Handle(GetConversationsQuery query, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var conversations = await _conversationsRepository.GetPagedResultAsync(userId, query.pageParams);
            if(conversations.Count == 0)
                return Result.Failure<PagedResult<DtoConversationShortInfo>>("Список даилогов пуст");
            var otherUserIds = conversations.Data
            .SelectMany(x => new[] { x.Participant1Id, x.Participant2Id })
            .Distinct()
            .Where(id => id != userId)
            .ToList();
            var users = await _userRepository.GetUsersByIds(otherUserIds); 
            var userNames = users.ToDictionary(u => u.Key, u => u.Value);

            var result = conversations.Data.Select(с => 
            {
                var otherUserId = с.Participant1Id == userId ? с.Participant2Id : с.Participant1Id;
                return new DtoConversationShortInfo
                {
                    Id = с.Id,
                    UserName = userNames.GetValueOrDefault(otherUserId, "Пустое имя"),
                    CountUreadMessages = с.ConversationMessages.Count(x => x.ReceiverId == userId && x.ConversationsId == с.Id),
                    LastMessageContent = с.ConversationMessages.Where(x => x.ConversationsId == с.Id).Select(x => x.Content).FirstOrDefault(),
                    LastMessageAt = с.LastMessageAt,
                };
              
            }).ToList();
            return Result.Success(new PagedResult<DtoConversationShortInfo>(result, result.Count));
        }
    }
}