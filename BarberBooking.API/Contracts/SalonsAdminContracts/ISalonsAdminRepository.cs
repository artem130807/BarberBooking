using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts.SalonsAdminContracts
{
    public interface ISalonsAdminRepository
    {
        Task Add(SalonsAdmin salonsAdmin);
        Task Delete(Guid Id);
        Task<SalonsAdmin> GetById(Guid Id);
        Task<List<SalonsAdmin>> GetSalonsAdmin(Guid userId);
        Task<bool> IsUserAdminOfSalonAsync(Guid userId, Guid salonId, CancellationToken cancellationToken = default);
        Task<List<Guid>> GetSalonIdsForUserAsync(Guid userId, CancellationToken cancellationToken = default);
    }
}