using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace IdentityService.KafkaServices.KafkaProducerLog
{
    public class KafkaSettingsLog
    {
        public string BootstrapServers {get ; set;}
        public string Topic {get; set;}
    }
}