using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using NotifyService.Application.Contracts;
using NotifyService.Domain.Models;

namespace NotifyService.Infrastructure.SignalR;

public class NotificationService : INotificationService
{
    private readonly IHubContext<NotificationHub> _hubContext;
    private readonly IFcmPushService _fcmPushService;
    private readonly ILogger<NotificationService> _logger;

    public NotificationService(
        IHubContext<NotificationHub> hubContext,
        IFcmPushService fcmPushService,
        ILogger<NotificationService> logger)
    {
        _hubContext = hubContext;
        _fcmPushService = fcmPushService;
        _logger = logger;
    }

    public async Task SendAppointmentNotification(PushAppointmentNotification message)
    {
        try
        {
            await _hubContext.Clients.User(message.UserId.ToString()).SendAsync("ReceiveNotification", new
            {
                Id = message.Id,
                Message = message.Content,
                Timestamp = DateTime.UtcNow
            });

            await _fcmPushService.SendAppointmentNotificationAsync(message);

            _logger.LogInformation("Notification sent to user {UserId}: {Message}", message.UserId, message.Content);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to send notification to user {UserId}", message.UserId);
        }
    }
}
