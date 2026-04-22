using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.ConversationsContracts;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Conversations.Commands.Handlers
{
    public class DeleteConversationHandler : IRequestHandler<DeleteConversationCommand, Result<bool>>
    {
        private readonly IConversationsRepository _conversationsRepository;
        private readonly IUnitOfWork _unitOfWork;
        public DeleteConversationHandler(IConversationsRepository conversationsRepository, IUnitOfWork unitOfWork)
        {
            _conversationsRepository = conversationsRepository;
            _unitOfWork = unitOfWork;
        }
        public async Task<Result<bool>> Handle(DeleteConversationCommand command, CancellationToken cancellationToken)
        {
            var conversation = await _conversationsRepository.GetConversation(command.Id);
            if(conversation == null)
                return false;
            try
            {
                _unitOfWork.Commit();
                await _unitOfWork.conversationsRepository.Delete(command.Id);
                _unitOfWork.BeginTransaction();
            }catch(Exception)
            {
                _unitOfWork.RollBack();
                return false;
            }
            return true;
        }
    }
}