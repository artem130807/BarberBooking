using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
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
        public GetConversationMessagesHandler(IConversationMessagesRepository conversationMessagesRepository, IMapper mapper)
        {
            _conversationMessagesRepository = conversationMessagesRepository;
            _mapper = mapper;
        }
        public async Task<Result<PagedResult<DtoConversationMessageShortInfo>>> Handle(GetConversationMessagesQuery query, CancellationToken cancellationToken)
        {
            var messages = await _conversationMessagesRepository.GetMessages(query.conversationId, query.pageParams);
            var result = _mapper.Map<PagedResult<DtoConversationMessageShortInfo>>(messages);
            return result;
        }
    }
}