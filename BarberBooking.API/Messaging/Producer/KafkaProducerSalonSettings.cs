using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Messaging.Producer
{
    public class KafkaProducerSalonSettings
    {
        public string BootstrapServers {get ; set;}
        public  Dictionary<string, string> Topics {get; set;} = new();
    }
}