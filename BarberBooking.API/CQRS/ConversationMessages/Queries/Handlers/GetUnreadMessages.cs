using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.ConversationMessagesContracts;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.ConversationMessages.Queries.Handlers
{
    public class GetUnreadMessagesHandler : IRequestHandler<GetUnreadMessagesQuery, Result<int>>
    {
        private readonly IConversationMessagesRepository _conversationMessagesRepository;
        private readonly IUserContext _userContext;
        public GetUnreadMessagesHandler(IConversationMessagesRepository conversationMessagesRepository, IUserContext userContext)
        {
            _conversationMessagesRepository = conversationMessagesRepository;
            _userContext = userContext;
        }
        public async Task<Result<int>> Handle(GetUnreadMessagesQuery query, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var count = await _conversationMessagesRepository.GetUnreadMessagesByUser(userId);
            if(count == 0)
                return 0;
            return Result.Success(count);
        }
    }
}