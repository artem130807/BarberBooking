using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Contracts
{
    public interface IUpdateRatingService
    {
        Task UpdateMasterRating(Guid aggregateId, Guid reviewId, int? masterRating, CancellationToken cancellationToken);
        Task UpdateSalonRating(Guid aggregateId, Guid reviewId, int? salonRating, CancellationToken cancellationToken);
    }
}