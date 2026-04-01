using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.ExtensionsProject;
using BarberBooking.API.Filters;
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
            return await _context.MasterProfiles.Include(x => x.Salon).Include(x => x.User).FirstOrDefaultAsync(x => x.Id == Id);
        }

        public async Task<MasterProfile> GetMasterProfileByUserId(Guid userId)
        {
            return await _context.MasterProfiles.FirstOrDefaultAsync(x => x.UserId == userId);
        }

        public async Task<List<MasterProfile>> GetMastersBySalon(Guid salondId)
        {
            return await _context.MasterProfiles.Include(x => x.Salon).Include(x => x.User).Where(x => x.SalonId == salondId).ToListAsync();
        }

        public async Task<PagedResult<MasterProfile>> GetMastersBySalonPaged(Guid salonId, PageParams pageParams)
        {
            return await _context.MasterProfiles
                .AsNoTracking()
                .Include(x => x.User)
                .Include(x => x.Salon)
                .Where(x => x.SalonId == salonId)
                .OrderBy(x => x.User.Name)
                .ToPagedAsync(pageParams);
        }

        public async Task<List<MasterProfile>> GetMastersBySalonFilter(Guid salonId, MasterProfileFilter filter)
        {
            return await _context.MasterProfiles.Where(x => x.SalonId == salonId).FilterMasterProfile(filter).ToListAsync();
        }

        public async Task<List<MasterProfile>> GetTheBestMasters(string city, int? take)
        {
            return await _context.MasterProfiles
            .Include(x => x.User)
            .Include(x => x.Salon)
            .Where(x => x.Salon.Address.City == city)
            .OrderByDescending(x => x.RatingCount)
            .ThenByDescending(x => x.Rating)
            .Take(take ?? 10)
            .ToListAsync();
        }


        public async Task<PagedResult<MasterProfile>> GetTopMastersInSalon(Guid salonId, PageParams pageParams)
        {
            return await _context.MasterProfiles
                .AsNoTracking()
                .Include(x => x.User)
                .Include(x => x.Salon)
                .Where(x => x.SalonId == salonId)
                .OrderByDescending(x => x.RatingCount)
                .ThenByDescending(x => x.Rating)
                .ToPagedAsync(pageParams);
        }

        public async Task UpdateAsync(MasterProfile master)
        {
            _context.MasterProfiles.Update(master);
            await _context.SaveChangesAsync();
        }
        public async Task<bool> UserIsSubscripeMaster(Guid userId, Guid masterId)
        {
            var subscripe = await _context.MasterSubscriptions.FirstOrDefaultAsync(x => x.ClientId == userId && x.MasterId == masterId);
            if(subscripe == null)
                return false;
            return true;
        }

        public async Task<List<MasterProfile>> GetMastersDayStats(int year, int month, int day, CancellationToken cancellationToken = default)
        {
            var start = new DateTime(year, month, day, 0, 0, 0, DateTimeKind.Utc);
            var end = start.AddDays(1);

            return await _context.MasterProfiles
                .AsSplitQuery()
                .Include(m => m.Appointments.Where(a => a.AppointmentDate >= start && a.AppointmentDate < end))
                    .ThenInclude(a => a.Service)
                .ToListAsync(cancellationToken);
        }
    }
}