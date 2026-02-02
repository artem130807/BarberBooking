using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace IdentityService.Consumers
{
    public class KafkaSettingsConsumer
    {
        public string BootstrapServers {get ; set;}
        public string Topic {get; set;}
        public string GroupId {get; set;}
    }
}