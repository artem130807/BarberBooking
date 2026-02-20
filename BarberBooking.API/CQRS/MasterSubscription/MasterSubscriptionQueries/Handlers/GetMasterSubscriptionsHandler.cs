using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterSubscriptionContracts;
using BarberBooking.API.Dto.DtoMasterSubscription;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterSubscription.MasterSubscriptionQueries.Handlers
{
    public class GetMasterSubscriptionsHandler : IRequestHandler<GetMasterSubscriptionsQuery, Result<List<DtoMasterSubscriptionShortInfo>>>
    {
        private readonly IMasterSubscriptionRepository _masterSubscriptionRepository;
        private readonly IMapper _mapper;
        private readonly IUserContext _userContext;
        public GetMasterSubscriptionsHandler(IMasterSubscriptionRepository masterSubscriptionRepository, IMapper mapper, IUserContext userContext)
        {
            _masterSubscriptionRepository = masterSubscriptionRepository;
            _mapper = mapper;
            _userContext = userContext;
        }
        public async Task<Result<List<DtoMasterSubscriptionShortInfo>>> Handle(GetMasterSubscriptionsQuery query, CancellationToken cancellationToken)
        {
            var userId = _userContext.UserId;
            var masterSubscriptions = await _masterSubscriptionRepository.GetMasterSubscriptions(userId);
            if(masterSubscriptions.Count == 0)
                return Result.Failure<List<DtoMasterSubscriptionShortInfo>>("Список ваших подписок пус");
            var result = _mapper.Map<List<DtoMasterSubscriptionShortInfo>>(masterSubscriptions);
            return Result.Success(result);
        }
    }
}