using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Hubs;
using BarberBooking.API.Models;
using Microsoft.AspNetCore.SignalR;

namespace BarberBooking.API.Service
{
    public class NotificationService : INotificationService
    {
        private readonly IHubContext<NotificationHub> _hubContext;
        private readonly ILogger<NotificationService> _logger;

        public NotificationService(IHubContext<NotificationHub> hubContext, ILogger<NotificationService> logger)
        {
            _hubContext = hubContext;
            _logger = logger;
        }

        public async Task SendAppointmentNotification(Messages message)
        {
            try
            {
                await _hubContext.Clients.User(message.UserId.ToString())
                    .SendAsync("ReceiveNotification", new
                    {
                        Id = message.Id,
                        Message = message.Content,
                        Timestamp = DateTime.UtcNow
                    });
                    
                _logger.LogInformation("Notification sent to user {UserId}: {Message}", message.UserId, message.Content);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send notification to user {UserId}", message.UserId);
            }
        }
    }
}