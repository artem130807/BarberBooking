using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.AppointmentContracts;

namespace BarberBooking.API.Service.Background
{
    public class AutoAppointmentsCancelledBackgroundService : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<AutoAppointmentsCancelledBackgroundService> _logger;
        private readonly TimeSpan _interval = TimeSpan.FromMinutes(5);
        public AutoAppointmentsCancelledBackgroundService(IServiceProvider serviceProvider, ILogger<AutoAppointmentsCancelledBackgroundService> logger)
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
                        .GetRequiredService<IAutoAppointmentsCancelledHandler>();
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