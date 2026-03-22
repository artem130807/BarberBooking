using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MessagesContracts;
using BarberBooking.API.Dto.DtoMessages;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Messages.Queries.Handleers
{
    public class GetMessagesHandler : IRequestHandler<GetMessagesQuery, Result<List<DtoMessagesShortInfo>>>
    {
        private readonly IMapper _mapper;
        private readonly IMessagesRepository _messagesRepository;
        private readonly IUserContext _userContext;
        private readonly IUnitOfWork _unitOfWork;
        public GetMessagesHandler(IMapper mapper, IMessagesRepository messagesRepository, IUserContext userContext, IUnitOfWork unitOfWork)
        {
            _mapper = mapper;  
            _messagesRepository = messagesRepository;
            _userContext = userContext;
            _unitOfWork = unitOfWork;
        }
        public async Task<Result<List<DtoMessagesShortInfo>>> Handle(GetMessagesQuery query, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var messages = await _messagesRepository.GetMessages(userId);
            if(messages.Count == 0)
                return Result.Failure<List<DtoMessagesShortInfo>>("Список уведомлений пуст");
            var result = _mapper.Map<List<DtoMessagesShortInfo>>(messages);
            try
            {
                _unitOfWork.BeginTransaction();
                foreach (var message in messages)
                {
                    if(message.IsVisible == false)
                    {
                        message.UpdateVisible(true);
                    }
                }
                await _unitOfWork.messagesRepository.UpdateRange(messages);
                _unitOfWork.Commit();
            }catch(Exception ex)
            {
                _unitOfWork.RollBack();
                return Result.Failure<List<DtoMessagesShortInfo>>($"{ex.Message}");
            }
            return Result.Success(result);
        }
    }
}