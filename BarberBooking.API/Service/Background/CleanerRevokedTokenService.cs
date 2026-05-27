using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;

namespace BarberBooking.API.Service.Background
{
    public class CleanerRevokedTokenService : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly TimeSpan _interval = TimeSpan.FromMinutes(15);
        private readonly ILogger<CleanerRevokedTokenService> _logger;
        public CleanerRevokedTokenService(IServiceProvider serviceProvider,  ILogger<CleanerRevokedTokenService> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }
        protected async override Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                  using (var scope = _serviceProvider.CreateScope())
                    {
                        var handlerSalon = scope.ServiceProvider
                        .GetRequiredService<ICleanerRevokedTokenHandler>();
                        await handlerSalon.Handle(stoppingToken);
                    }
                    _logger.LogInformation($"Жду {_interval.TotalMinutes} минут до следующей обработки");
                    await Task.Delay(_interval, stoppingToken);   
                }catch(Exception ex)
                {
                    _logger.LogError(ex.Message);
                }    
            }
        }
    }
}