using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.SalonsContracts;

namespace BarberBooking.API.Service.Background
{
    public class SalonBackground : BackgroundService
    {
        private readonly ISalonActiveHandler _salonActiveHandler;
        public SalonBackground(ISalonActiveHandler salonActiveHandler)
        {
            _salonActiveHandler = salonActiveHandler;
        }
        protected override Task ExecuteAsync(CancellationToken stoppingToken)
        {
            throw new NotImplementedException();
        }
    }
}