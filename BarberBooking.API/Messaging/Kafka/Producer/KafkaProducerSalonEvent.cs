using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Domain;
using Confluent.Kafka;
using Microsoft.Extensions.Options;

namespace BarberBooking.API.Messaging.Producer
{
    public class KafkaProducerSalonEvent<TMessage> : IKafkaProducerSalonEvent<TMessage> where TMessage:DomainEvent
    {
        private readonly IProducer<string, TMessage> producer;
        private readonly string _topic;
        public KafkaProducerSalonEvent(IOptions<KafkaProducerSalonSettings> options)
        {
            var config = new ProducerConfig
            {
              BootstrapServers = options.Value.BootstrapServers  
            };
            producer = new ProducerBuilder<string, TMessage>(config).SetValueSerializer(new KafkaJsonSerializer<TMessage>())
            .Build();

            var typeName = typeof(TMessage).Name;
            if (!options.Value.Topics.TryGetValue(typeName, out _topic))
            {
                throw new InvalidOperationException(
                $"No topic configured for type {typeName}. " +
                $"Available topics: {string.Join(", ", options.Value.Topics.Keys)}");
            }
        }
        public void Dispose()
        {
            producer?.Dispose();
        }

        public async Task ProduceAsync(TMessage message, CancellationToken cancellationToken)
        {
            await producer.ProduceAsync(_topic, new Message<string, TMessage>()
            {
                Key = Guid.NewGuid().ToString(),
                Value = message 
            }, cancellationToken);
        }
    }
}