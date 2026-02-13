using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.ExtensionsProject;
using BarberBooking.API.Filters.MasterProfile;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Repositories
{
    public class MasterProfileRepository : IMasterProfileRepository
    {
        private readonly BarberBookingDbContext _context;
        public MasterProfileRepository(BarberBookingDbContext context)
        {
            _context = context;
        }
        public async Task<MasterProfile> CreateMasterProfile(MasterProfile masterProfile)
        {
            _context.Add(masterProfile);
            return masterProfile;
        }
        public async Task DeleteMasterProfile(Guid Id)
        {
            await _context.MasterProfiles.Where(x => x.Id == Id).ExecuteDeleteAsync();
        }
        public async Task<MasterProfile> GetMasterProfileById(Guid Id)
        {
            return await _context.MasterProfiles.Include(x => x.User).FirstOrDefaultAsync(x => x.Id == Id);
        }

        public async Task<MasterProfile> GetMasterProfileByUserId(Guid userId)
        {
            return await _context.MasterProfiles.FirstOrDefaultAsync(x => x.UserId == userId);
        }

        public async Task<List<MasterProfile>> GetMastersBySalon(Guid salondId)
        {
            return await _context.MasterProfiles.Include(x => x.User).Where(x => x.SalonId == salondId).ToListAsync();
        }

        public async Task<List<MasterProfile>> GetMastersBySalonFilter(Guid salonId, MasterProfileFilter filter)
        {
            return await _context.MasterProfiles.Where(x => x.SalonId == salonId).FilterMasterProfile(filter).ToListAsync();
        }
    }
}