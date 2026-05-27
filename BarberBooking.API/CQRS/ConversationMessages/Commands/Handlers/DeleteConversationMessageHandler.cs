using System;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.ConversationMessagesContracts;
using BarberBooking.API.Contracts.ConversationsContracts;
using BarberBooking.API.Hubs;
using CSharpFunctionalExtensions;
using MediatR;
using Microsoft.AspNetCore.SignalR;

namespace BarberBooking.API.CQRS.ConversationMessages.Commands.Handlers
{
    public class DeleteConversationMessageHandler : IRequestHandler<DeleteConversationMessageCommand, Result<bool>>
    {
        private readonly IConversationMessagesRepository _conversationMessagesRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IConversationsRepository _conversationsRepository;
        private readonly IUserContext _userContext;
        private readonly IHubContext<ChatHub> _hubContext;

        public DeleteConversationMessageHandler(
            IConversationMessagesRepository conversationMessagesRepository,
            IUnitOfWork unitOfWork,
            IConversationsRepository conversationsRepository,
            IUserContext userContext,
            IHubContext<ChatHub> hubContext)
        {
            _conversationMessagesRepository = conversationMessagesRepository;
            _unitOfWork = unitOfWork;
            _conversationsRepository = conversationsRepository;
            _userContext = userContext;
            _hubContext = hubContext;
        }

        public async Task<Result<bool>> Handle(DeleteConversationMessageCommand command, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var message = await _conversationMessagesRepository.GetMessage(command.Id);

            if (message == null)
                return Result.Failure<bool>("Сообщение не найдено");

            var conversation = await _conversationsRepository.GetConversation(message.ConversationsId);

            if (conversation == null)
                return Result.Failure<bool>("Диалог не найден");

            if (!conversation.HasParticipant(userId))
                return Result.Failure<bool>("Доступ запрещён");

            if (message.SenderId != userId)
                return Result.Failure<bool>("Доступ запрещён");

            var previousMessage =
                await _conversationMessagesRepository.GetMessageByNotId(message.Id, conversation.Id);

            try
            {
                _unitOfWork.BeginTransaction();
                conversation.UpdateLastMessage(previousMessage?.CreatedAt);
                await _unitOfWork.conversationMessagesRepository.Delete(command.Id);
                _unitOfWork.Commit();
            }
            catch (Exception)
            {
                _unitOfWork.RollBack();
                return Result.Failure<bool>("Не удалось удалить сообщение");
            }

            try
            {
                await _hubContext.Clients.Group($"conversation_{message.ConversationsId}")
                    .SendAsync("MessageDeleted", new { message.Id });
            }
            catch (Exception)
            {
            }

            return Result.Success(true);
        }
    }
}
