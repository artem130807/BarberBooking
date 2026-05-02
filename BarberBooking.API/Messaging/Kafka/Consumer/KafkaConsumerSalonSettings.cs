using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Messaging.Consumer
{
    public class KafkaConsumerSalonSettings
    {
        public string BootstrapServers {get ; set;}
        public string Topic {get; set;}
        public string GroupId {get; set;}
    }
}