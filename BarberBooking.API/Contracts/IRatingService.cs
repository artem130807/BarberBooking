using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Contracts
{
    public interface IRatingService
    {

        Task<Result> AddSalonRating(Guid SalonId, int RatingCount, CancellationToken cancellationToken);
        Task<Result> AddMasterRating(Guid MasterId, int MasterRating, CancellationToken cancellationToken);
    }
}