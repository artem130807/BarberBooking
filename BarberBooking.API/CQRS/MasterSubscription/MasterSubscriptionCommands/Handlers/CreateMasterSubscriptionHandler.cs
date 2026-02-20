using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterSubscriptionContracts;
using BarberBooking.API.CQRS.MasterProfile.Commands;
using BarberBooking.API.Dto.DtoMasterProfile;
using BarberBooking.API.Dto.DtoMasterSubscription;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterSubscription.MasterSubscriptionCommands.Handlers
{
    public class CreateMasterSubscriptionHandler : IRequestHandler<CreateMasterSubscriptionCommand, Result<DtoMasterSubscriptionInfo>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMasterSubscriptionRepository _masterSubscriptionRepository;
        private readonly IUserContext _userContext;
        private readonly IMapper _mapper;
        public CreateMasterSubscriptionHandler(IUnitOfWork unitOfWork, IMasterSubscriptionRepository masterSubscriptionRepository, IUserContext userContext, IMapper mapper)
        {
            _unitOfWork = unitOfWork;
            _masterSubscriptionRepository = masterSubscriptionRepository;
            _userContext = userContext;
            _mapper = mapper;
        }
        public async Task<Result<DtoMasterSubscriptionInfo>> Handle(CreateMasterSubscriptionCommand command, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var masterSubscription = await _masterSubscriptionRepository.GetMasterSubscriptionByMasterIdAndClientId(command.dtoCreateMasterSubscription.MasterId, userId);
            if(masterSubscription != null)
                return Result.Failure<DtoMasterSubscriptionInfo>("Такая подписка уже существует");
            var CreateMasterSubscription = Models.MasterSubscription.Create(userId, command.dtoCreateMasterSubscription.MasterId);
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.masterSubscriptionRepository.Add(CreateMasterSubscription);
                _unitOfWork.Commit();
            }catch(Exception e)
            {
                _unitOfWork.RollBack();
                return Result.Failure<DtoMasterSubscriptionInfo>(e.Message);
            }
            var result = _mapper.Map<DtoMasterSubscriptionInfo>(CreateMasterSubscription);
            return Result.Success(result);
        }
    }
}