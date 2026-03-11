using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.MasterSubscriptionContracts;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Repositories
{
    public class MasterSubscriptionRepository : IMasterSubscriptionRepository
    {
        private readonly BarberBookingDbContext _context;
        public MasterSubscriptionRepository(BarberBookingDbContext context)
        {
            _context = context;
        }
        public async Task<MasterSubscription> Add(MasterSubscription masterSubscription)
        {
            _context.MasterSubscriptions.Add(masterSubscription);
            return masterSubscription;
        }

        public async Task Delete(Guid Id)
        {
            await _context.MasterSubscriptions.Where(x => x.Id == Id).ExecuteDeleteAsync();
        }

        public async Task<MasterSubscription> GetMasterSubscriptionById(Guid Id)
        {
            return await _context.MasterSubscriptions.FindAsync(Id);
        }

        public async Task<MasterSubscription> GetMasterSubscriptionByMasterIdAndClientId(Guid masterId, Guid userId)
        {
            return await _context.MasterSubscriptions.FirstOrDefaultAsync(x => x.MasterId == masterId && x.ClientId == userId);
        }

        public async Task<List<MasterSubscription>> GetMasterSubscriptions(Guid userId)
        {
            return await _context.MasterSubscriptions.Include(x => x.MasterProfile).ThenInclude(x => x.User).Where(x => x.ClientId == userId).ToListAsync();
        }
    }
}