using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;

namespace BarberBooking.API.Service.Background
{
    public class SalonStatiscticBackgroundService : BackgroundService
    {
        private readonly ILogger<SalonStatiscticBackgroundService> _logger;
         private readonly IServiceProvider _serviceProvider;
        private readonly TimeSpan _interval = TimeSpan.FromMinutes(1);

        public SalonStatiscticBackgroundService(ILogger<SalonStatiscticBackgroundService> logger, IServiceProvider serviceProvider)
        {
            _logger = logger;
            _serviceProvider = serviceProvider;
        }
        protected async override Task ExecuteAsync(CancellationToken stoppingToken)
        {
            try
            {
                while (!stoppingToken.IsCancellationRequested)
                {
                    using (var scope = _serviceProvider.CreateScope())
                    {
                        var handlerSalon = scope.ServiceProvider
                        .GetRequiredService<ISalonStatiscticHandler>();
                        await handlerSalon.Handle(stoppingToken);
                    }
                    _logger.LogInformation($"Жду {_interval.TotalMinutes} минут до следующей обработки");
                    await Task.Delay(_interval, stoppingToken);
                }
            }catch(Exception ex)
            {
                _logger.LogError(ex.Message);
            }
        }
    }
}