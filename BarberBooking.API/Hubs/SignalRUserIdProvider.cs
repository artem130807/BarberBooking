using System.Security.Claims;
using Microsoft.AspNetCore.SignalR;

namespace BarberBooking.API.Hubs
{
    public sealed class SignalRUserIdProvider : IUserIdProvider
    {
        public string? GetUserId(HubConnectionContext connection)
        {
            var user = connection.User;
            if (user?.Identity?.IsAuthenticated != true)
                return null;
            return user.FindFirstValue("userId")
                ?? user.FindFirstValue(ClaimTypes.NameIdentifier);
        }
    }
}
