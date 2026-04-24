using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.ConversationMessagesContracts;
using BarberBooking.API.Contracts.ConversationsContracts;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.ConversationMessages.Commands.Handlers
{
    public class DeleteConversationMessageHandler : IRequestHandler<DeleteConversationMessageCommand, Result<bool>>
    {
        private readonly IConversationMessagesRepository _conversationMessagesRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IConversationsRepository _conversationsRepository;
        public DeleteConversationMessageHandler(IConversationMessagesRepository conversationMessagesRepository, IUnitOfWork unitOfWork, IConversationsRepository conversationsRepository)
        {
            _conversationMessagesRepository = conversationMessagesRepository;
            _unitOfWork = unitOfWork;
            _conversationsRepository = conversationsRepository;
        }
        public async Task<Result<bool>> Handle(DeleteConversationMessageCommand command, CancellationToken cancellationToken)
        {
            var message = await _conversationMessagesRepository.GetMessage(command.Id);
            if(message == null)
                return Result.Failure<bool>("Сообщение не найдено");
            var conversation = await _conversationsRepository.GetConversation(message.ConversationsId);
            if(conversation == null)
                return Result.Failure<bool>("Диалог не найден"); 
            var lastMessage = await _conversationMessagesRepository.GetMessageByNotId(message.Id, conversation.Id);
            try
            {
                _unitOfWork.BeginTransaction();
                conversation.UpdateLastMessage(lastMessage.CreatedAt);
                await _unitOfWork.conversationMessagesRepository.Delete(command.Id);
                _unitOfWork.Commit();
            }catch(Exception)
            {
                _unitOfWork.RollBack();
                return false;
            }
            return true;
        }
    }
}