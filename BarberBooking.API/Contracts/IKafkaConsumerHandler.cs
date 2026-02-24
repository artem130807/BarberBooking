using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Domain;

namespace BarberBooking.API.Contracts
{
    public interface IKafkaConsumerHandler<TMessage>:IDisposable where TMessage: DomainEvent
    {
        Task<List<TMessage>> ReadEvents(Guid aggregateId,int fromVersion = 0, CancellationToken cancellationToken = default);
    }
}