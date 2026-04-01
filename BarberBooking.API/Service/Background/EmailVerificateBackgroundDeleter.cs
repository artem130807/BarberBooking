using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.EmailContracts;

namespace BarberBooking.API.Service.Background
{
    public class EmailVerificateBackgroundDeleter:BackgroundService
    {
        private readonly ILogger<EmailVerificateBackgroundDeleter> _logger;
        private readonly IServiceProvider _serviceProvider;
        private readonly TimeSpan _interval = TimeSpan.FromMinutes(5);
        public EmailVerificateBackgroundDeleter(ILogger<EmailVerificateBackgroundDeleter> logger,IServiceProvider serviceProvider)
        {
            _logger = logger;
            _serviceProvider = serviceProvider;
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
                        .GetRequiredService<IEmailVerficationHandler>();
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
