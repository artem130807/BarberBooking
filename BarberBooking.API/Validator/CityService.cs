using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using Microsoft.Extensions.Caching.Memory;

namespace BarberBooking.API.Validator
{
    public class CityService : ICityService
    {
        private readonly IMemoryCache _memoryCache;
        private const string CityNamesCacheKey = "key_cities_names";

        public CityService(IMemoryCache memoryCache)
        {
            _memoryCache = memoryCache;
        }
        public  bool IsCityValid(string cityName)
        {
            if (string.IsNullOrWhiteSpace(cityName))
            {
                return false;
            }

            if (!_memoryCache.TryGetValue<HashSet<string>>(CityNamesCacheKey, out var cityNames) || cityNames is null)
            {
                return false;
            }

            return cityNames.Contains(cityName.ToLowerInvariant());
        }
    }
}