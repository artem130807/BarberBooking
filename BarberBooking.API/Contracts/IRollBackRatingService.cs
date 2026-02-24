using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Contracts
{
    public interface IRollBackRatingService
    {
        Task<Result> RollBackSalonRating(Guid AggregateId, Guid reviewId, CancellationToken cancellationToken);
        Task<Result> RollBackMasterRating(Guid AggregateId, Guid reviewId, CancellationToken cancellationToken);
    }
}