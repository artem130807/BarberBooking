using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using Microsoft.Extensions.Caching.Memory;

namespace BarberBooking.API.Service
{
    public class CacheService : ICacheService
    {
        private readonly IMemoryCache _memoryCache;
        public CacheService(IMemoryCache memoryCache)
        {
            _memoryCache = memoryCache;
        }
        public async Task AddCache<T>(string key, T value, CancellationToken cancellationTokend)
        {
            _memoryCache.Set(key, value);
        }

        public async Task<T> GetCacheByKey<T>(string key, CancellationToken cancellationToken)
        {
            var cache = _memoryCache.Get<T>(key);
            return cache;
        }

        public async Task RemoveCacheByKey(string key, CancellationToken cancellationToken)
        {
            _memoryCache.Remove(key);
        }
    }
}