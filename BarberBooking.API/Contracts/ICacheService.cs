using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Contracts
{
    public interface ICacheService
    {
        Task<T> GetCacheByKey<T>(string key, CancellationToken cancellationToken);
        Task AddCache<T>(string key, T value ,CancellationToken cancellationTokend); 
        Task RemoveCacheByKey(string key, CancellationToken cancellationToken);
    }
}