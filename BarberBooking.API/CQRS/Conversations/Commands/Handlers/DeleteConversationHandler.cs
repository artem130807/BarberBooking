using System;
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
        private readonly IUserContext _userContext;

        public DeleteConversationHandler(
            IConversationsRepository conversationsRepository,
            IUnitOfWork unitOfWork,
            IUserContext userContext)
        {
            _conversationsRepository = conversationsRepository;
            _unitOfWork = unitOfWork;
            _userContext = userContext;
        }

        public async Task<Result<bool>> Handle(DeleteConversationCommand command, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var conversation = await _conversationsRepository.GetConversation(command.Id);

            if (conversation == null)
                return Result.Failure<bool>("Диалог не найден");

            if (!conversation.HasParticipant(userId))
                return Result.Failure<bool>("Доступ запрещён");

            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.conversationsRepository.Delete(command.Id);
                _unitOfWork.Commit();
            }
            catch (Exception)
            {
                _unitOfWork.RollBack();
                return Result.Failure<bool>("Не удалось удалить диалог");
            }

            return Result.Success(true);
        }
    }
}
