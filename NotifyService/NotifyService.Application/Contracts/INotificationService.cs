using NotifyService.Domain.Models;

namespace NotifyService.Application.Contracts;

public interface INotificationService
{
    Task SendAppointmentNotification(PushAppointmentNotification message);
}
