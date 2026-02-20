using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterSubscriptionContracts;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterSubscription.MasterSubscriptionCommands.Handlers
{
    public class DeleteMasterSubscriptionHandler : IRequestHandler<DeleteMasterSubscriptionCommand, Result<string>>
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMasterSubscriptionRepository _masterSubscriptionRepository;
        public DeleteMasterSubscriptionHandler(IUnitOfWork unitOfWork, IMasterSubscriptionRepository masterSubscriptionRepository)
        {
            _unitOfWork = unitOfWork;
            _masterSubscriptionRepository = masterSubscriptionRepository;
        }
        public async Task<Result<string>> Handle(DeleteMasterSubscriptionCommand command, CancellationToken cancellationToken)
        {
            var masterSubscription = await _masterSubscriptionRepository.GetMasterSubscriptionById(command.Id);
            if(masterSubscription == null)
                return Result.Failure<string>("Подписка не найдена");
            try
            {
                _unitOfWork.BeginTransaction();
                await _unitOfWork.masterSubscriptionRepository.Delete(command.Id);
                _unitOfWork.Commit();
            }catch(Exception e)
            {
                _unitOfWork.RollBack();
                return Result.Failure<string>(e.Message);
            }
            return Result.Success("Успешно");
        }
    }
}