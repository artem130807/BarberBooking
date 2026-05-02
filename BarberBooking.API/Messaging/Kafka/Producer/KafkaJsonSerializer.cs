using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using Confluent.Kafka;

namespace BarberBooking.API.Messaging.Producer
{
    public class KafkaJsonSerializer<TMessage>: ISerializer<TMessage>
    {
        private static readonly JsonSerializerOptions Options = new JsonSerializerOptions
        {
            Encoder = System.Text.Encodings.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping
        };

        public byte[] Serialize(TMessage data, SerializationContext context)
        {
            return JsonSerializer.SerializeToUtf8Bytes(data, Options);
        }
    }
}