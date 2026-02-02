using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Confluent.Kafka;
using IdentityService.Contracts;
using Microsoft.Extensions.Options;
using Newtonsoft.Json.Linq;

namespace IdentityService.Consumers
{
    public class KafkaConsumerService<TMessage> : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly string _topic;
        private readonly IConsumer<string, TMessage> _consumer;
        private readonly ILogger<KafkaConsumerService<TMessage>> _logger;
        public KafkaConsumerService(IOptions<KafkaSettingsConsumer> options, ILogger<KafkaConsumerService<TMessage>> logger, IServiceProvider serviceProvider)
        {
            _serviceProvider = serviceProvider;
            var config = new ConsumerConfig
            {
                BootstrapServers = options.Value.BootstrapServers,
                GroupId = options.Value.GroupId
            };
            _topic = options.Value.Topic;
            _consumer = new ConsumerBuilder<string, TMessage>(config).SetValueDeserializer(new KafkaValueDeserializer<TMessage>()).Build();
            _logger = logger;
        }
        protected override Task ExecuteAsync(CancellationToken stoppingToken)
        {
            return Task.Run(() => ConsumeAsync(stoppingToken));
        }
        private async Task? ConsumeAsync(CancellationToken stoppingToken)
        {
            _consumer.Subscribe(_topic);
            try
            {
                while (!stoppingToken.IsCancellationRequested)
                {
                   var result =  _consumer.Consume(stoppingToken);
                   var message = result.Message.Value;
                    using (var scope = _serviceProvider.CreateScope())
                    {
                        var messageHandler = scope.ServiceProvider
                        .GetRequiredService<IMessageHandler<TMessage>>();
                        await messageHandler.HandleAsync(result.Message.Value, stoppingToken);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }
        public override Task StopAsync(CancellationToken cancellationToken)
        {
            _consumer.Close();
            return base.StopAsync(cancellationToken);
        }
    }
}