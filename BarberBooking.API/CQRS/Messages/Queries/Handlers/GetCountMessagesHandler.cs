using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MessagesContracts;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Messages.Queries.Handlers
{
    public class GetCountMessagesHandler : IRequestHandler<GetCountMessagesQuery, Result<int>>
    {
        private readonly IMessagesRepository _messagesRepository;
        private readonly IUserContext _userContext;
        public GetCountMessagesHandler(IMessagesRepository messagesRepository, IUserContext userContext)
        {
            _messagesRepository = messagesRepository;
            _userContext = userContext;
        }
        public async Task<Result<int>> Handle(GetCountMessagesQuery query, CancellationToken cancellationToken)
        {
            if (!_userContext.IsAuthenticated || _userContext.UserId == Guid.Empty)
                return Result.Failure<int>("Требуется авторизация");
            var userId = _userContext.UserId;
            var messages = await _messagesRepository.GetUnreadMessages(userId);
            if(messages.Count == 0)
                return Result.Success(0);
            return Result.Success(messages.Count());
        }
    }
}