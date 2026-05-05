namespace NotifyService.Domain.Models;

public class PushAppointmentNotification
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string? Content { get; set; }
    public Guid? AppointmentId { get; set; }
}
