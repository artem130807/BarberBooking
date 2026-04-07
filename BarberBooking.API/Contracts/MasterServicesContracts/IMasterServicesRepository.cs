using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts.MasterServicesContracts
{
    public interface IMasterServicesRepository
    {
        Task<MasterServices?> GetByIdAsync(Guid id);
        Task<List<MasterServices>> GetByMasterProfileIdAsync(Guid masterProfileId);
        Task<bool> ExistsAsync(Guid masterProfileId, Guid serviceId);
        Task<MasterServices> AddAsync(MasterServices entity);
        Task DeleteAsync(Guid id);
    }
}
