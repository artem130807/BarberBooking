using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.ConversationMessagesContracts;
using BarberBooking.API.Contracts.ConversationsContracts;
using BarberBooking.API.Dto.DtoConversationMessages;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.ConversationMessages.Queries.Handlers
{
    public class GetConversationMessagesHandler : IRequestHandler<GetConversationMessagesQuery, Result<PagedResult<DtoConversationMessageShortInfo>>>
    {
        private readonly IConversationMessagesRepository _conversationMessagesRepository;
        private readonly IConversationsRepository _conversationsRepository;
        private readonly IMapper _mapper;
        private readonly IUserContext _userContext;
        private readonly IUpdateUreadMessagesService _updateUreadMessagesService;

        public GetConversationMessagesHandler(
            IConversationMessagesRepository conversationMessagesRepository,
            IConversationsRepository conversationsRepository,
            IMapper mapper,
            IUserContext userContext,
            IUpdateUreadMessagesService updateUreadMessagesService)
        {
            _conversationMessagesRepository = conversationMessagesRepository;
            _conversationsRepository = conversationsRepository;
            _mapper = mapper;
            _userContext = userContext;
            _updateUreadMessagesService = updateUreadMessagesService;
        }

        public async Task<Result<PagedResult<DtoConversationMessageShortInfo>>> Handle(GetConversationMessagesQuery query, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var conversation = await _conversationsRepository.GetConversation(query.conversationId);

            if (conversation == null)
                return Result.Failure<PagedResult<DtoConversationMessageShortInfo>>("Диалог не найден");

            if (!conversation.HasParticipant(userId))
                return Result.Failure<PagedResult<DtoConversationMessageShortInfo>>("Доступ запрещён");

            var messages = await _conversationMessagesRepository.GetMessages(query.conversationId, query.pageParams);
            await _updateUreadMessagesService.Update(query.conversationId, userId);

            return Result.Success(_mapper.Map<PagedResult<DtoConversationMessageShortInfo>>(messages));
        }
    }
}
