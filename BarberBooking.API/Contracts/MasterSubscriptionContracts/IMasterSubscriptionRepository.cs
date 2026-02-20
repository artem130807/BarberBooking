using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts.MasterSubscriptionContracts
{
    public interface IMasterSubscriptionRepository
    {
        Task<MasterSubscription> Add(MasterSubscription masterSubscription);
        Task Delete(Guid Id);
        Task<List<MasterSubscription>> GetMasterSubscriptions(Guid userId);
        Task<MasterSubscription> GetMasterSubscriptionById(Guid Id);
        Task<MasterSubscription> GetMasterSubscriptionByMasterIdAndClientId(Guid masterId, Guid userId);
    }
}