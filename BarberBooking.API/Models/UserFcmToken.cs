using System;

namespace BarberBooking.API.Models;


public class UserFcmToken
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Users User { get; set; } = null!;
    public string Token { get; set; } = null!;
    public DateTime UpdatedAt { get; set; }
}
