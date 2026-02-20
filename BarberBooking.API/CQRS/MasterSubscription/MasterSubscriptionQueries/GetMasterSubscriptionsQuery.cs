using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoMasterSubscription;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterSubscription.MasterSubscriptionQueries
{
    public record GetMasterSubscriptionsQuery():IRequest<Result<List<DtoMasterSubscriptionShortInfo>>>;
    
}