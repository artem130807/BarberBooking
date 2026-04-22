using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Dto.DtoConversation;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Conversations.Commands.Handlers
{
    public class CreateConversationHandler : IRequestHandler<CreateConversationCommand, Result<bool>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IUserContext _userContext;
        public CreateConversationHandler(IUnitOfWork unitOfWork, IUserContext userContext) 
        {
            _unitOfWork = unitOfWork;
            _userContext = userContext;
        }
        public async Task<Result<bool>> Handle(CreateConversationCommand command, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var conversation = Models.Conversations.Create(userId, command.participant2Id);
            if(conversation.IsFailure)
                return false;
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.conversationsRepository.Add(conversation.Value);
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