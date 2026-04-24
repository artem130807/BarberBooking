using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.ConversationMessagesContracts;
using BarberBooking.API.Dto.DtoConversation;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.ConversationMessages.Commands.Handlers
{ 
    public class UpdateConversationMessageHandler : IRequestHandler<UpdateConversationMessageCommand, Result<DtoConversationInfo>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IConversationMessagesRepository _conversationMessagesRepository;
        private readonly IMapper _mapper;
        public UpdateConversationMessageHandler(IUnitOfWork unitOfWork, IConversationMessagesRepository conversationMessagesRepository, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _conversationMessagesRepository = conversationMessagesRepository;
            _mapper = mapper;
        }
        public async Task<Result<DtoConversationInfo>> Handle(UpdateConversationMessageCommand command, CancellationToken cancellationToken)
        {
            var message = await _conversationMessagesRepository.GetMessage(command.Id);
            if(message == null)
                return Result.Failure<DtoConversationInfo>("Сообщение не найдено");
            try
            {
                _unitOfWork.BeginTransaction();
                message.UpdateContent(message.Content);
                _unitOfWork.Commit();
            }catch(Exception)
            {
                _unitOfWork.RollBack();
            }
            var result = _mapper.Map<DtoConversationInfo>(message);
            return Result.Success(result);
        }
    }
}