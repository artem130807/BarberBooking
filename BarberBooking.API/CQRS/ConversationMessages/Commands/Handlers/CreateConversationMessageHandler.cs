using System;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.ConversationMessagesContracts;
using BarberBooking.API.Contracts.ConversationsContracts;
using BarberBooking.API.Dto.DtoConversationMessages;
using BarberBooking.API.Hubs;
using CSharpFunctionalExtensions;
using MediatR;
using Microsoft.AspNetCore.SignalR;

namespace BarberBooking.API.CQRS.ConversationMessages.Commands.Handlers
{
    public class CreateConversationMessageHandler : IRequestHandler<CreateConversationMessageCommand, Result<DtoConversationMessageInfo>>
    {
        private readonly IConversationsRepository _conversationsRepository;
        private readonly IConversationMessagesRepository _conversationMessagesRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IUserContext _userContext;
        private readonly IMapper _mapper;
        private readonly IHubContext<ChatHub> _hubContext;

        public CreateConversationMessageHandler(
            IConversationsRepository conversationsRepository,
            IConversationMessagesRepository conversationMessagesRepository,
            IUnitOfWork unitOfWork,
            IUserContext userContext,
            IMapper mapper,
            IHubContext<ChatHub> hubContext)
        {
            _conversationsRepository = conversationsRepository;
            _conversationMessagesRepository = conversationMessagesRepository;
            _unitOfWork = unitOfWork;
            _userContext = userContext;
            _mapper = mapper;
            _hubContext = hubContext;
        }

        public async Task<Result<DtoConversationMessageInfo>> Handle(CreateConversationMessageCommand command, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var conversation = await _conversationsRepository.GetConversation(command.dtoCreateConversationMessage.ConversationId);

            if (conversation == null)
                return Result.Failure<DtoConversationMessageInfo>("Диалог не найден");

            if (!conversation.HasParticipant(userId))
                return Result.Failure<DtoConversationMessageInfo>("Доступ запрещён");

            var receiverId = conversation.Participant1Id == userId
                ? conversation.Participant2Id
                : conversation.Participant1Id;

            var message = Models.ConversationMessages.Create(
                conversation.Id,
                userId,
                receiverId,
                command.dtoCreateConversationMessage.Content,
                false,
                null);

            if (message.IsFailure)
                return Result.Failure<DtoConversationMessageInfo>(message.Error);

            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.conversationMessagesRepository.Add(message.Value);
                conversation.UpdateLastMessage(message.Value.CreatedAt);
                _unitOfWork.Commit();
            }
            catch (Exception)
            {
                _unitOfWork.RollBack();
                return Result.Failure<DtoConversationMessageInfo>("Не удалось сохранить сообщение");
            }

            var saved = await _conversationMessagesRepository.GetMessage(message.Value.Id);
            var dto = _mapper.Map<DtoConversationMessageInfo>(saved ?? message.Value);

            try
            {
                await _hubContext.Clients.Group($"conversation_{message.Value.ConversationsId}")
                    .SendAsync("ReceiveMessage", dto, cancellationToken);
            }
            catch (Exception)
            {
            }

            return Result.Success(dto);
        }
    }
}
