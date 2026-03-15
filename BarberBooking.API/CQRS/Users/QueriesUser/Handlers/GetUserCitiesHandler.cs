using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using CSharpFunctionalExtensions;
using MediatR;
using Microsoft.Extensions.Caching.Memory;

namespace BarberBooking.API.CQRS.Users.QueriesUser.Handlers
{
    public class GetUserCitiesHandler : IRequestHandler<GetUserCitiesQuery, Result<List<string>>>
    {
        private const string CityNamesCacheKey = "key_cities_names";
        private readonly IMemoryCache _memoryCache;
        public GetUserCitiesHandler(IMemoryCache memoryCache)
        {
            _memoryCache = memoryCache;
        }
        public async Task<Result<List<string>>> Handle(GetUserCitiesQuery query, CancellationToken cancellationToken)
        {
            if (!_memoryCache.TryGetValue<HashSet<string>>(CityNamesCacheKey, out var cityNames) || cityNames is null)
            {
                return Result.Failure<List<string>>("Не удалось получить значение");
            }
            List<string> groupedCities = cityNames
                .GroupBy(city => char.ToUpper(city[0]))
                .OrderBy(group => group.Key)
                .SelectMany(group => group.OrderBy(city => city))
                .ToList();
            if(!string.IsNullOrWhiteSpace(query.city))
                groupedCities = groupedCities.Where(x => x.StartsWith(query.city.ToLower())).ToList();

            return Result.Success(groupedCities);
        }
    }
}