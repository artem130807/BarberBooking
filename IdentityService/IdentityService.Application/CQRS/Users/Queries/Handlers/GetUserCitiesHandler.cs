using CSharpFunctionalExtensions;
using MediatR;
using Microsoft.Extensions.Caching.Memory;

namespace IdentityService.Application.CQRS.Users.Queries.Handlers;

public class GetUserCitiesHandler : IRequestHandler<GetUserCitiesQuery, Result<List<string>>>
{
    private const string CityNamesCacheKey = "key_cities_names";
    private readonly IMemoryCache _memoryCache;

    public GetUserCitiesHandler(IMemoryCache memoryCache)
    {
        _memoryCache = memoryCache;
    }

    public Task<Result<List<string>>> Handle(GetUserCitiesQuery query, CancellationToken cancellationToken)
    {
        if (!_memoryCache.TryGetValue<HashSet<string>>(CityNamesCacheKey, out var cityNames) || cityNames is null)
            return Task.FromResult(Result.Failure<List<string>>("РќРµ СѓРґР°Р»РѕСЃСЊ РїРѕР»СѓС‡РёС‚СЊ Р·РЅР°С‡РµРЅРёРµ"));

        var grouped = cityNames
            .GroupBy(city => char.ToUpper(city[0]))
            .OrderBy(group => group.Key)
            .SelectMany(group => group.OrderBy(city => city))
            .ToList();

        if (!string.IsNullOrWhiteSpace(query.city))
        {
            var prefix = query.city.ToLowerInvariant();
            grouped = grouped.Where(x => x.StartsWith(prefix, StringComparison.Ordinal)).ToList();
        }

        return Task.FromResult(Result.Success(grouped));
    }
}
