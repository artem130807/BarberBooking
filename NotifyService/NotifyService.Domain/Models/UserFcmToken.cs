namespace NotifyService.Domain.Models;

public class UserFcmToken
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string Token { get; set; } = string.Empty;
    public DateTime UpdatedAt { get; set; }
}
