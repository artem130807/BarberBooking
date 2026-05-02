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
    public class GetConversationsBySearchHandler : IRequestHandler<GetConversationsBySearchQuery, Result<PagedResult<DtoConversationShortInfo>>>
    {
        private readonly IConversationsRepository _conversationsRepository;
        private readonly IUserContext _userContext;
        private readonly IUserRepository _userRepository;
        public GetConversationsBySearchHandler(IConversationsRepository conversationsRepository, IUserContext userContext, IUserRepository userRepository)
        {
            _conversationsRepository = conversationsRepository;
            _userContext = userContext;
            _userRepository = userRepository;
        }
        public async Task<Result<PagedResult<DtoConversationShortInfo>>> Handle(GetConversationsBySearchQuery query, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var conversations = await _conversationsRepository.GetConversationBySearch(userId, query.filter, query.pageParams);
            if(conversations.Count == 0)
                return Result.Failure<PagedResult<DtoConversationShortInfo>>("Список диалогов пуст");
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