using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityService.Events;

namespace IdentityService.KafkaServices.KafkaProducerLog
{
    public interface IKafkaProducerLogService<in TMessage>:IDisposable where TMessage:ApprovalEventBase
    {
        Task ProduceAsync(TMessage message, CancellationToken cancellationToken);
    }
}