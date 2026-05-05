using IdentityService.Application.Contracts;
using Microsoft.Extensions.Caching.Memory;

namespace IdentityService.Infrastructure.Validators;

public class CityService : ICityService
{
    private const string CityNamesCacheKey = "key_cities_names";

    private readonly IMemoryCache _memoryCache;

    public CityService(IMemoryCache memoryCache)
    {
        _memoryCache = memoryCache;
    }

    public bool IsCityValid(string cityName)
    {
        if (string.IsNullOrWhiteSpace(cityName))
            return false;

        if (!_memoryCache.TryGetValue<HashSet<string>>(CityNamesCacheKey, out var cityNames) || cityNames is null)
            return false;

        return cityNames.Contains(cityName.ToLowerInvariant());
    }
}
