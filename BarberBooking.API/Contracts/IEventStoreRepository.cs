using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Domain;

namespace BarberBooking.API.Contracts
{
    public interface IEventStoreRepository
    {
        Task<IEnumerable<DomainEvent>> GetEventsAsync(Guid aggregateId);
        Task<IEnumerable<DomainEvent>> GetAllRatingEventsExcept(Guid aggregateId,  DateTime excludeEventTime);
        Task SaveEventsAsync(Guid aggregateId, IEnumerable<DomainEvent> events);
        Task<IEnumerable<DomainEvent>> GetAllEventsAsync();
        Task<IEnumerable<DomainEvent>> GetEventsAfterDateAsync(DateTime afterDate);
        Task<DomainEvent> GetLastEvent(Guid aggregateId);
        Task<int> GetLastVersion(Guid SalonId);
        Task<DomainEvent> GetPreviousEvent(Guid aggregateId, DateTime eventTime);
    }
}