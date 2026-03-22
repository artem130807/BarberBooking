using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MessagesContracts;

namespace BarberBooking.API.Service.Background
{
    public class MessageAppointmentBackgroundService : BackgroundService
    {
        private readonly ILogger<MessageAppointmentBackgroundService> _logger;
        private readonly IServiceProvider _serviceProvider;
        private readonly TimeSpan _interval = TimeSpan.FromMinutes(1);
        public MessageAppointmentBackgroundService(ILogger<MessageAppointmentBackgroundService> logger, IServiceProvider serviceProvider)
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
                        .GetRequiredService<IMessageAppointmentHandler>();
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