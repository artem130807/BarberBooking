using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.ConversationMessagesContracts;
using BarberBooking.API.Contracts.ConversationsContracts;
using BarberBooking.API.Dto.DtoConversationMessages;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.ConversationMessages.Commands.Handlers
{
    public class CreateConversationMessageHandler : IRequestHandler<CreateConversationMessageCommand, Result<DtoConversationMessageInfo>>
    {
        private readonly IConversationsRepository _conversationsRepository;
        private readonly IConversationMessagesRepository _conversationMessagesRepository;
        private readonly IUnitOfWork _unitOfWork;
        private readonly IUserContext _userContext;
        private readonly IMapper _mapper;
        public CreateConversationMessageHandler(IConversationsRepository conversationsRepository, IConversationMessagesRepository conversationMessagesRepository, IUnitOfWork unitOfWork, IUserContext userContext,  IMapper mapper)
        {
            _conversationsRepository = conversationsRepository;
            _conversationMessagesRepository = conversationMessagesRepository;
            _unitOfWork = unitOfWork;
            _userContext = userContext;
            _mapper = mapper;
        }
        public async Task<Result<DtoConversationMessageInfo>> Handle(CreateConversationMessageCommand command, CancellationToken cancellationToken)
        { 
            var userId = _userContext.UserId;
            var conversation = await _conversationsRepository.GetConversation(command.dtoCreateConversationMessage.ConversationId);
            if(conversation == null)
                return Result.Failure<DtoConversationMessageInfo>("Диалог не найден");

            var conversationIds = new List<Guid>{conversation.Participant1Id, conversation.Participant2Id};

            var receiverId = conversationIds.FirstOrDefault(x => x != userId);
          
            var message = Models.ConversationMessages.Create(conversation.Id, userId, receiverId, command.dtoCreateConversationMessage.Content, false, null);
            if(message.IsFailure)
                return Result.Failure<DtoConversationMessageInfo>("Ошибка при отправке сообщения");
            try
            {
                _unitOfWork.Commit();
                await _unitOfWork.conversationMessagesRepository.Add(message.Value);
                conversation.UpdateLastMessage(message.Value.CreatedAt);
                _unitOfWork.BeginTransaction();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
            }
            var result = _mapper.Map<DtoConversationMessageInfo>(message.Value );
            return result;
        }
    }
}