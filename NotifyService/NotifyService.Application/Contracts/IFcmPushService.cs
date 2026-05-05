using NotifyService.Domain.Models;

namespace NotifyService.Application.Contracts;

public interface IFcmPushService
{
    Task SendAppointmentNotificationAsync(PushAppointmentNotification message,
        CancellationToken cancellationToken = default);
}
