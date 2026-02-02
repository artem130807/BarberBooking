using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace IdentityService.KafkaServices
{
    public interface IKafkaProducerService<in TMessage>:IDisposable
    {
        Task ProduceAsync(TMessage message, CancellationToken cancellationToken);
    }
}