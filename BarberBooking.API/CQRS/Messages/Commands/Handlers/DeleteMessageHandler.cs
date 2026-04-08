using System;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MessagesContracts;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Messages.Commands.Handlers
{
    public class DeleteMessageHandler : IRequestHandler<DeleteMessageCommand, Result<string>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMessagesRepository _messagesRepository;
        private readonly IUserContext _userContext;
        private readonly ILogger<DeleteMessageHandler> _logger;
        public DeleteMessageHandler(
            IUnitOfWork unitOfWork,
            IMessagesRepository messagesRepository,
            IUserContext userContext,
            ILogger<DeleteMessageHandler> logger)
        {
            _unitOfWork = unitOfWork;
            _messagesRepository = messagesRepository;
            _userContext = userContext;
            _logger = logger;
        }
        public async Task<Result<string>> Handle(DeleteMessageCommand command, CancellationToken cancellationToken)
        {
            var message = await _messagesRepository.GetMessageByIdAsync(command.Id);
            if (message == null)
                return Result.Failure<string>("Не удалось найти сообщение");
            if (message.UserId != _userContext.UserId)
                return Result.Failure<string>("Нет доступа");
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.messagesRepository.Delete(command.Id);
                _unitOfWork.Commit();
            }
            catch (Exception ex)
            {
                _unitOfWork.RollBack();
                _logger.LogError(ex.Message);
                return Result.Failure<string>("Не удалось удалить сообщение");
            }
            return Result.Success("Успешно");
        }
    }
}
