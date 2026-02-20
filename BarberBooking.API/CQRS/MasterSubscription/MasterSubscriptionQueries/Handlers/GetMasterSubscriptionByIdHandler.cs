using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts.MasterSubscriptionContracts;
using BarberBooking.API.CQRS.MasterProfile.Queries;
using BarberBooking.API.Dto.DtoMasterSubscription;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterSubscription.MasterSubscriptionQueries.Handlers
{
    public class GetMasterSubscriptionByIdHandler : IRequestHandler<GetMasterProfileByIdQuery, Result<DtoMasterSubscriptionInfo>>
    {
        private readonly IMapper _mapper;
        private readonly IMasterSubscriptionRepository _masterSubscriptionRepository;
        public GetMasterSubscriptionByIdHandler(IMapper mapper, IMasterSubscriptionRepository masterSubscriptionRepository)
        {
            _mapper = mapper;
            _masterSubscriptionRepository = masterSubscriptionRepository;
        }
        public async Task<Result<DtoMasterSubscriptionInfo>> Handle(GetMasterProfileByIdQuery query, CancellationToken cancellationToken)
        {
            var masterSubscription = await _masterSubscriptionRepository.GetMasterSubscriptionById(query.Id);
            if(masterSubscription == null)
                return Result.Failure<DtoMasterSubscriptionInfo>("Подписка не найдена");
            var result = _mapper.Map<DtoMasterSubscriptionInfo>(masterSubscription);
            return Result.Success(result);
        }
    }
}