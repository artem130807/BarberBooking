using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Models
{
    public class MasterServices
    {
        public Guid Id {get; private set;}
        public Guid MasterProfileId {get; private set;}
        public Guid ServiceId {get; private set;}
        public Services Service {get; private set;}
        public MasterProfile MasterProfile {get ; private set;}

        public static Result<MasterServices> Create(Guid masterProfileId, Guid serviceId)
        {
            var masterService = new MasterServices
            {
               Id = Guid.NewGuid(),
               MasterProfileId =  masterProfileId,
               ServiceId = serviceId 
            };
            return masterService;
        }
    }
}