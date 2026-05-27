using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.ConversationMessagesContracts;
using BarberBooking.API.Contracts.ConversationsContracts;
using BarberBooking.API.Dto.DtoConversationMessages;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.ConversationMessages.Queries.Handlers
{
    public class GetConversationMessageHandler : IRequestHandler<GetConversationMessageQuery, Result<DtoConversationMessageInfo>>
    {
        private readonly IConversationMessagesRepository _conversationMessagesRepository;
        private readonly IConversationsRepository _conversationsRepository;
        private readonly IUserContext _userContext;
        private readonly IMapper _mapper;

        public GetConversationMessageHandler(
            IConversationMessagesRepository conversationMessagesRepository,
            IConversationsRepository conversationsRepository,
            IUserContext userContext,
            IMapper mapper)
        {
            _conversationMessagesRepository = conversationMessagesRepository;
            _conversationsRepository = conversationsRepository;
            _userContext = userContext;
            _mapper = mapper;
        }

        public async Task<Result<DtoConversationMessageInfo>> Handle(GetConversationMessageQuery query, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var message = await _conversationMessagesRepository.GetMessage(query.Id);
            if (message == null)
                return Result.Failure<DtoConversationMessageInfo>("Сообщение не найдено");

            var conversation = await _conversationsRepository.GetConversation(message.ConversationsId);

            if (conversation == null)
                return Result.Failure<DtoConversationMessageInfo>("Диалог не найден");

            if (!conversation.HasParticipant(userId))
                return Result.Failure<DtoConversationMessageInfo>("Доступ запрещён");

            return Result.Success(_mapper.Map<DtoConversationMessageInfo>(message));
        }
    }
}
