using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Confluent.Kafka;
using IdentityService.Events;
using Microsoft.Extensions.Options;

namespace IdentityService.KafkaServices.KafkaProducerLog
{
    public class KafkaProducerLogService<TMessage> : IKafkaProducerLogService<TMessage> where TMessage : ApprovalEventBase
    {
        private readonly IProducer<string, TMessage> producer;
        private readonly string topic;
        public KafkaProducerLogService(IOptions<KafkaSettingsLog> options)
        {
            var config = new ProducerConfig
            {
              BootstrapServers = options.Value.BootstrapServers  
            };
            producer = new ProducerBuilder<string, TMessage>(config).SetValueSerializer(new KafkaJsonSerializer<TMessage>())
            .Build();
            topic = options.Value.Topic;
        }
        public void Dispose()
        {
            producer?.Dispose();
        }  
        public async Task ProduceAsync(TMessage message, CancellationToken cancellationToken)
        {
            await producer.ProduceAsync(topic, new Message<string, TMessage>()
            {
                Key = Guid.NewGuid().ToString(),
                Value = message 
            }, cancellationToken);
        }
    }
}