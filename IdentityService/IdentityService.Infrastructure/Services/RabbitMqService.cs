using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using IdentityService.Application.Contracts;
using RabbitMQ.Client;

namespace IdentityService.Infrastructure.Services
{
    public class RabbitMqService : IRabbitMqService
    {
        public async Task SendMessage(object obj)
        {
            var message = JsonSerializer.Serialize(obj);
            await SendMessage(message);
        }

        private async Task SendMessage(string message)
        {
            var factory = new ConnectionFactory() 
            { 
                HostName = "localhost",
                Port = 5672,
                UserName = "admin",
                Password = "admin123"
            };
            var connection = await factory.CreateConnectionAsync();
            var channel = await connection.CreateChannelAsync();
            try
            {
                await channel.QueueDeclareAsync(queue: "MyQueue",
                    durable: false,
                    exclusive: false,
                    autoDelete: false,
                    arguments: null);

                var body = Encoding.UTF8.GetBytes(message);
                await channel.BasicPublishAsync(exchange: "",
                    routingKey: "MyQueue",
                    body: body);
            }
            finally
            {
                await channel.CloseAsync();
                await connection.CloseAsync();
            }
        }
    }
}