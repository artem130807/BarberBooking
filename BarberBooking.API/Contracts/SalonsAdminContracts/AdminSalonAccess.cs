using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Contracts.SalonsAdminContracts
{
    public class AdminSalonAccess
    {
        private readonly ISalonsAdminRepository _salonsAdminRepository;
        private readonly IUserContext _userContext;

        public AdminSalonAccess(ISalonsAdminRepository salonsAdminRepository, IUserContext userContext)
        {
            _salonsAdminRepository = salonsAdminRepository;
            _userContext = userContext;
        }

        public Task<bool> OwnsSalonAsync(Guid salonId, CancellationToken cancellationToken = default) =>
            _salonsAdminRepository.IsUserAdminOfSalonAsync(_userContext.UserId, salonId, cancellationToken);

        public async Task<Result> RequireSalonAsync(Guid salonId, CancellationToken cancellationToken = default)
        {
            if (!await OwnsSalonAsync(salonId, cancellationToken))
                return Result.Failure("Нет доступа к этому салону");
            return Result.Success();
        }

        public Task<List<Guid>> GetMySalonIdsAsync(CancellationToken cancellationToken = default) =>
            _salonsAdminRepository.GetSalonIdsForUserAsync(_userContext.UserId, cancellationToken);
    }
}
