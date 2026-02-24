using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Domain;

namespace BarberBooking.API.Contracts.SalonsContracts
{
    public interface IKafkaProducerSalonEvent<TMessage>:IDisposable where TMessage:DomainEvent
    {
        Task ProduceAsync(TMessage message, CancellationToken cancellationToken);
    }
}