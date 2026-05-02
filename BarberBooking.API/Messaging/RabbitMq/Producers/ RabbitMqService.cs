using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using RabbitMQ.Client;

namespace BarberBooking.API.Messaging.RabbitMq.Producers
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
           var factory = new ConnectionFactory() { HostName = "localhost" };
            await using var connection = await factory.CreateConnectionAsync();
            await using var channel = await connection.CreateChannelAsync();
            
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
        
    }
}