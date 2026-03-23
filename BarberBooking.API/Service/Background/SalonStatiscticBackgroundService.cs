using System;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.SalonsContracts;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace BarberBooking.API.Service.Background
{
    public class SalonStatiscticBackgroundService : BackgroundService
    {
        private readonly ILogger<SalonStatiscticBackgroundService> _logger;
        private readonly IServiceProvider _serviceProvider;

        private const int RunHourUtc = 23;

        private const int RunMinuteUtc = 0;

        public SalonStatiscticBackgroundService(
            ILogger<SalonStatiscticBackgroundService> logger,
            IServiceProvider serviceProvider)
        {
            _logger = logger;
            _serviceProvider = serviceProvider;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            try
            {
                while (!stoppingToken.IsCancellationRequested)
                {
                    var delay = GetDelayUntilNextEndOfMonthRunUtc(DateTime.UtcNow, RunHourUtc, RunMinuteUtc);
                    var nextRun = DateTime.UtcNow.Add(delay);
                    _logger.LogInformation(
                        "Следующий запуск месячной статистики через {Delay} (план: ~{NextRun:u}, последний день месяца {Hour:D2}:{Minute:D2} UTC)",
                        delay, nextRun, RunHourUtc, RunMinuteUtc);

                    try
                    {
                        await Task.Delay(delay, stoppingToken);
                    }
                    catch (OperationCanceledException)
                    {
                        break;
                    }

                    if (stoppingToken.IsCancellationRequested)
                        break;

                    using (var scope = _serviceProvider.CreateScope())
                    {
                        var handler = scope.ServiceProvider.GetRequiredService<ISalonStatiscticHandler>();
                        await handler.Handle(stoppingToken);
                    }
                }
            }
            catch (OperationCanceledException)
            {
                
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Ошибка в фоновом сервисе месячной статистики салонов");
            }
        }


        internal static TimeSpan GetDelayUntilNextEndOfMonthRunUtc(DateTime utcNow, int hourUtc, int minuteUtc)
        {
            if (hourUtc is < 0 or > 23 || minuteUtc is < 0 or > 59)
                throw new ArgumentOutOfRangeException("Некорректное время UTC.");

            var lastDay = DateTime.DaysInMonth(utcNow.Year, utcNow.Month);
            var candidate = new DateTime(utcNow.Year, utcNow.Month, lastDay, hourUtc, minuteUtc, 0, DateTimeKind.Utc);

            if (utcNow < candidate)
                return candidate - utcNow;

            var nextMonth = new DateTime(utcNow.Year, utcNow.Month, 1, 0, 0, 0, DateTimeKind.Utc).AddMonths(1);
            lastDay = DateTime.DaysInMonth(nextMonth.Year, nextMonth.Month);
            var next = new DateTime(nextMonth.Year, nextMonth.Month, lastDay, hourUtc, minuteUtc, 0, DateTimeKind.Utc);
            return next - utcNow;
        }
    }
}
