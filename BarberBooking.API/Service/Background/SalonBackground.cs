using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.SalonsContracts;

namespace BarberBooking.API.Service.Background
{
    public class SalonBackground : BackgroundService
    {
        private readonly ILogger<SalonBackground> _logger;
        private readonly IServiceProvider _serviceProvider;
        private readonly TimeSpan _interval = TimeSpan.FromMinutes(5);
        public SalonBackground(ILogger<SalonBackground> logger, IServiceProvider serviceProvider)
        {
            _logger = logger;
            _serviceProvider = serviceProvider;
            _logger.LogInformation("Background Salon включен");
        }
        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            try
            {
                while (!stoppingToken.IsCancellationRequested)
                {
                    using (var scope = _serviceProvider.CreateScope())
                    {
                        var handler = scope.ServiceProvider
                        .GetRequiredService<ISalonActiveHandler>();
                        await handler.Handle(stoppingToken);
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