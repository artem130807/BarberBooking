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
    public class UpdateConversationMessageHandler : IRequestHandler<UpdateConversationMessageCommand, Result<DtoConversationMessageInfo>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IConversationMessagesRepository _conversationMessagesRepository;
        private readonly IConversationsRepository _conversationsRepository;
        private readonly IUserContext _userContext;
        private readonly IMapper _mapper;
        private readonly IHubContext<ChatHub> _hubContext;

        public UpdateConversationMessageHandler(
            IUnitOfWork unitOfWork,
            IConversationMessagesRepository conversationMessagesRepository,
            IConversationsRepository conversationsRepository,
            IUserContext userContext,
            IMapper mapper,
            IHubContext<ChatHub> hubContext)
        {
            _unitOfWork = unitOfWork;
            _conversationMessagesRepository = conversationMessagesRepository;
            _conversationsRepository = conversationsRepository;
            _userContext = userContext;
            _mapper = mapper;
            _hubContext = hubContext;
        }

        public async Task<Result<DtoConversationMessageInfo>> Handle(UpdateConversationMessageCommand command, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var message = await _conversationMessagesRepository.GetMessage(command.Id);

            if (message == null)
                return Result.Failure<DtoConversationMessageInfo>("Сообщение не найдено");

            var conversation = await _conversationsRepository.GetConversation(message.ConversationsId);

            if (conversation == null)
                return Result.Failure<DtoConversationMessageInfo>("Диалог не найден");

            if (!conversation.HasParticipant(userId))
                return Result.Failure<DtoConversationMessageInfo>("Доступ запрещён");

            if (message.SenderId != userId)
                return Result.Failure<DtoConversationMessageInfo>("Доступ запрещён");

            try
            {
                _unitOfWork.BeginTransaction();
                message.UpdateContent(command.content);
                _unitOfWork.Commit();
            }
            catch (Exception)
            {
                _unitOfWork.RollBack();
                return Result.Failure<DtoConversationMessageInfo>("Не удалось обновить сообщение");
            }

            var dto = _mapper.Map<DtoConversationMessageInfo>(message);

            try
            {
                await _hubContext.Clients.Group($"conversation_{message.ConversationsId}")
                    .SendAsync("MessageUpdated", dto, cancellationToken);
            }
            catch (Exception)
            {
            }

            return Result.Success(dto);
        }
    }
}
