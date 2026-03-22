using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.MasterProfile;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts.MasterProfileContracts
{
    public interface IMasterProfileRepository
    {
        Task<MasterProfile> CreateMasterProfile(MasterProfile masterProfile);
        Task DeleteMasterProfile(Guid Id);
        Task<MasterProfile> GetMasterProfileById(Guid Id);
        Task<List<MasterProfile>> GetMastersBySalon(Guid salondId);
        Task<PagedResult<MasterProfile>> GetMastersBySalonPaged(Guid salonId, PageParams pageParams);
        Task<MasterProfile> GetMasterProfileByUserId(Guid userId);
        Task<List<MasterProfile>> GetMastersBySalonFilter(Guid salonId, MasterProfileFilter filter);
        Task<List<MasterProfile>> GetTheBestMasters(string city, int? take);
        Task UpdateAsync(MasterProfile master);
        Task<PagedResult<MasterProfile>> GetTopMastersInSalon(Guid salonId, PageParams pageParams);
    }
}