using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Domain;
using Confluent.Kafka;
using Microsoft.Extensions.Options;

namespace BarberBooking.API.Messaging.Consumer
{
    public class KafkaConsumerSalonEvent<TMessage>:IKafkaConsumerHandler<TMessage> where TMessage: DomainEvent
    {
        private readonly string _topic;
        private readonly IConsumer<string, TMessage> _consumer;
        private readonly ILogger<KafkaConsumerSalonEvent<TMessage>> _logger;
        public KafkaConsumerSalonEvent(IOptions<KafkaConsumerSalonSettings> options, ILogger<KafkaConsumerSalonEvent<TMessage>> logger)
        {
            _logger = logger;
            var config = new ConsumerConfig
            {
                BootstrapServers = options.Value.BootstrapServers,
                GroupId = options.Value.GroupId
            };
            _topic = options.Value.Topic;
            _consumer = new ConsumerBuilder<string, TMessage>(config).SetValueDeserializer(new KafkaValueDeserializer<TMessage>()).Build();
            _consumer.Subscribe(_topic);
            _logger.LogInformation($"Подписался на топик {_topic}");
        }

        public async Task<List<TMessage>> ReadEvents(Guid aggregateId,int fromVersion = 0, CancellationToken cancellationToken = default)
        {
            var events = new List<TMessage>();
            var timeout = TimeSpan.FromSeconds(5);
            
            try
            {
                _logger.LogInformation($"Начинаю обработку");
                while (!cancellationToken.IsCancellationRequested)
                {
                    var consumeResult = _consumer.Consume(timeout);
                    
                    if (consumeResult?.Message?.Value == null)
                        break;
                        
                    var @event = consumeResult.Message.Value;
                    
                    if (@event.AggregateId == aggregateId && @event.Version >= fromVersion)
                    {
                        events.Add(@event);
                        _consumer.Commit(consumeResult);
                    }
                }

                return events.OrderBy(e => e.Version).ToList();
            }
            catch (ConsumeException ex)
            {
                _logger.LogError(ex, "Error reading events");
                throw;
            }
        }
        public void Dispose()
        {
            _consumer?.Close();
            _consumer?.Dispose();
        }
    }
}