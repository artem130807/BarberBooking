using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace BarberBooking.API.Contracts.FcmPushContracts;

public interface IUserFcmTokenRepository
{
    Task UpsertTokenAsync(Guid userId, string token, CancellationToken cancellationToken = default);

    Task<IReadOnlyList<string>> GetTokensForUserAsync(Guid userId, CancellationToken cancellationToken = default);

    Task RemoveTokenAsync(Guid userId, string token, CancellationToken cancellationToken = default);
}
