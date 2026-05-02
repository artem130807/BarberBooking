using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.ConversationMessagesContracts;
using BarberBooking.API.Dto.DtoConversationMessages;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MailKit;
using MediatR;

namespace BarberBooking.API.CQRS.ConversationMessages.Queries.Handlers
{
    public class GetConversationMessagesHandler : IRequestHandler<GetConversationMessagesQuery, Result<PagedResult<DtoConversationMessageShortInfo>>>
    {
        private readonly IConversationMessagesRepository _conversationMessagesRepository;
        private readonly IMapper _mapper;
        private readonly IUserContext _userContext;
        private readonly IUpdateUreadMessagesService _updateUreadMessagesService;
        public GetConversationMessagesHandler(IConversationMessagesRepository conversationMessagesRepository, IMapper mapper, IUserContext userContext, IUpdateUreadMessagesService updateUreadMessagesService)
        {
            _conversationMessagesRepository = conversationMessagesRepository;
            _mapper = mapper;
            _userContext = userContext;
            _updateUreadMessagesService = updateUreadMessagesService;
        }
        public async Task<Result<PagedResult<DtoConversationMessageShortInfo>>> Handle(GetConversationMessagesQuery query, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var messages = await _conversationMessagesRepository.GetMessages(query.conversationId, query.pageParams);
            if(messages.Count == 0)
                return Result.Failure<PagedResult<DtoConversationMessageShortInfo>>("Список сообщений пуст"); 
            var result = messages.Data.Select(x => new DtoConversationMessageShortInfo
            { 
                Id = x.Id,
                SenderName = x.Sender.Name,
                Content = x.Content,
                IsRead = x.IsRead,
                SendTime = x.CreatedAt
            }).ToList();
            await _updateUreadMessagesService.Update(query.conversationId, userId);
            return new PagedResult<DtoConversationMessageShortInfo>(result, result.Count);
        }
    }
}