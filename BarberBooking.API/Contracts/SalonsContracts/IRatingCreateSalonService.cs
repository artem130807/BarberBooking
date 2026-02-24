using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Contracts.SalonsContracts
{
    public interface IRatingCreateSalonService
    {
        Task<Result> AddRating(Guid salonId, CancellationToken cancellationToken);
    }
}