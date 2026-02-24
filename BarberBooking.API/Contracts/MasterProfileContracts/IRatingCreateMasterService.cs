using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Contracts.MasterProfileContracts
{
    public interface IRatingCreateMasterService
    {
        Task<Result> AddRating(Guid masterId, CancellationToken cancellationToken);
    }
}