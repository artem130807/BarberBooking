using System.Text.Json;
using IdentityService.Application.Contracts;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Caching.Memory;

namespace IdentityService.Infrastructure.Validators;

public class LoadingCityService : ILoadingCityService
{
    private const string CacheKey = "key_cities_names";

    private readonly IMemoryCache _memoryCache;
    private readonly IWebHostEnvironment _env;

    public LoadingCityService(IMemoryCache memoryCache, IWebHostEnvironment env)
    {
        _memoryCache = memoryCache;
        _env = env;
    }

    public HashSet<string> CreateCityNames()
    {
        var filePath = Path.Combine(_env.ContentRootPath, "Data", "cities.json");
        var json = File.ReadAllText(filePath);
        using var document = JsonDocument.Parse(json);
        var cities = document.RootElement
            .GetProperty("lists")
            .GetProperty("cities")
            .EnumerateArray()
            .Select(c => c.GetProperty("city").GetString())
            .Where(name => !string.IsNullOrEmpty(name))
            .Select(name => name!.ToLowerInvariant())
            .ToList();

        HashSet<string> cityNames = [.. cities];
        _memoryCache.Set(CacheKey, cityNames);
        return cityNames;
    }
}
