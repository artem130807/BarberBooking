using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
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
        Task<MasterProfile> GetMasterProfileByUserId(Guid userId);
        Task<List<MasterProfile>> GetMastersBySalonFilter(Guid salonId, MasterProfileFilter filter);
    }
}