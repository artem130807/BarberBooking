using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Domain;
using BarberBooking.API.Messaging.Consumer;
using BarberBooking.API.Messaging.Producer;

namespace BarberBooking.API.ExtensionsProject
{
    public static class KafkaServiceExtensions
    {
        public static void AddProducer<TMessage>(this IServiceCollection services, IConfigurationSection section) where TMessage:DomainEvent
        {
            services.Configure<KafkaProducerSalonSettings>(section);
            services.AddSingleton<IKafkaProducerSalonEvent<TMessage>, KafkaProducerSalonEvent<TMessage>>();
        }
        public static IServiceCollection AddKafkaConsumer(this IServiceCollection services, IConfiguration configuration)
        {
            services.Configure<KafkaConsumerSalonSettings>(configuration.GetSection("Kafka"));
            services.Configure<KafkaProducerSalonSettings>(configuration.GetSection("Kafka"));
            services.AddScoped(typeof(IKafkaConsumerHandler<>), typeof(KafkaConsumerSalonEvent<>));
            services.AddScoped(typeof(IKafkaProducerSalonEvent<>), typeof(KafkaProducerSalonEvent<>));
            return services;
        }
    }
}