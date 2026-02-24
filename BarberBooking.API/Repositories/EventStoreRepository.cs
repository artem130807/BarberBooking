using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Domain;
using BarberBooking.API.Domain.SalonDomain;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Repositories
{
    public class EventStoreRepository:IEventStoreRepository
    {
        private readonly BarberBookingDbContext _context;
        public EventStoreRepository(BarberBookingDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<DomainEvent>> GetAllEventsAsync()
        {
            var events = await _context.EventStores.OrderBy(x => x.Version).ToListAsync();
            return events.Select(x => x.Deserialize());
        }

        public async Task<IEnumerable<DomainEvent>> GetEventsAfterDateAsync(DateTime afterDate)
        {
            var entities = await _context.EventStores.Where(x => x.OccurredAt == afterDate).OrderBy(x => x.Version).ToListAsync();
            return entities.Select(x => x.Deserialize());
        }

        public async Task<IEnumerable<DomainEvent>> GetEventsAsync(Guid aggregateId)
        {
            var entities = await _context.EventStores.Where(x => x.AggregateId == aggregateId).OrderBy(x => x.Version).ToListAsync();
            return entities.Select(x => x.Deserialize());
        }

        public async Task<DomainEvent> GetLastEvent(Guid aggregateId)
        {
            var entity = await _context.EventStores
            .Where(x => x.AggregateId == aggregateId)
            .OrderByDescending(x => x.Version) 
            .FirstOrDefaultAsync();             
            
            if (entity == null)
            return null;
    
            return entity.Deserialize();
        }

        public async Task<int> GetLastVersion(Guid SalonId)
        {
            var lastEvent = await _context.EventStores
            .Where(x => x.AggregateId == SalonId)
            .OrderByDescending(x => x.Version)
            .FirstOrDefaultAsync();
            
            return lastEvent?.Version ?? 0;
        }

        public async Task SaveEventsAsync(Guid aggregateId, IEnumerable<DomainEvent> events)
        {
            var lastVersion = await GetLastVersion(aggregateId);
            var version = lastVersion;
            
            var entities = new List<EventStore>();
            
            foreach (var @event in events)
            {
                @event.UpdateVersion(version); 
                
                var entity = EventStore.Create(@event);
                entities.Add(entity);
                
                Console.WriteLine($"Saving event: {@event.EventType} with version {version}");
            }
            
            await _context.EventStores.AddRangeAsync(entities);
        }
        public async Task<DomainEvent> GetPreviousEvent(Guid aggregateId, DateTime eventTime)
        {
            return await _context.EventStores
                .Where(x => x.AggregateId == aggregateId && x.OccurredAt < eventTime)
                .OrderByDescending(x => x.OccurredAt)
                .Select(x => x.Deserialize())
                .FirstOrDefaultAsync();
        }

        public async Task<IEnumerable<DomainEvent>> GetAllRatingEventsExcept(Guid aggregateId,  DateTime excludeEventTime)
        {
            var tolerance = TimeSpan.FromMilliseconds(100);
            var startTime = excludeEventTime.Subtract(tolerance);
            var endTime = excludeEventTime.Add(tolerance);

            var addEventType = typeof(SalonAddRatingEvent).FullName;
            var rollbackEventType = typeof(SalonRatingRollbackedEvent).FullName;

            var events = await _context.EventStores
                .Where(x => x.AggregateId == aggregateId
                    && (x.EventType == addEventType || x.EventType == rollbackEventType)
                    && (x.OccurredAt < startTime || x.OccurredAt > endTime))
                .OrderBy(x => x.Version)
                .Select(x => x.Deserialize())
                .ToListAsync();
            return events;
        }
    }
}