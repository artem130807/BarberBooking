using System;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.MasterProfileContracts;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace BarberBooking.API.Service.Background
{
    public class MasterStatisticBackgroundService : BackgroundService
    {
        private readonly ILogger<MasterStatisticBackgroundService> _logger;
        private readonly IServiceProvider _serviceProvider;

        private const int RunHourUtc = 23;
        private const int RunMinuteUtc = 1;

        public MasterStatisticBackgroundService(
            ILogger<MasterStatisticBackgroundService> logger,
            IServiceProvider serviceProvider)
        {
            _logger = logger;
            _serviceProvider = serviceProvider;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    var delay = DelayUntilNextRunUtc();
                    _logger.LogInformation(
                        "Следующий запуск статистики мастеров: {NextRunUtc} (через {Delay})",
                        DateTime.UtcNow.Add(delay),
                        delay);
                    await Task.Delay(delay, stoppingToken);
                }
                catch (OperationCanceledException)
                {
                    break;
                }

                if (stoppingToken.IsCancellationRequested)
                    break;

                try
                {
                    using var scope = _serviceProvider.CreateScope();
                    var handler = scope.ServiceProvider.GetRequiredService<IMasterStatisticHandler>();
                    await handler.Handle(stoppingToken);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Ошибка при генерации дневной статистики мастеров");
                }
            }
        }

        private static TimeSpan DelayUntilNextRunUtc()
        {
            var now = DateTime.UtcNow;
            var target = new DateTime(now.Year, now.Month, now.Day, RunHourUtc, RunMinuteUtc, 0, DateTimeKind.Utc);
            if (now >= target)
                target = target.AddDays(1);
            return target - now;
        }
    }
}
