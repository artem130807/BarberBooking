using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.FcmPushContracts;
using BarberBooking.API.Models;
using BarberBooking.API.Options;
using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace BarberBooking.API.Service;

public class FcmPushService : IFcmPushService
{
    private readonly IUserFcmTokenRepository _tokens;
    private readonly FirebasePushOptions _options;
    private readonly ILogger<FcmPushService> _logger;

    public FcmPushService(
        IUserFcmTokenRepository tokens,
        IOptions<FirebasePushOptions> options,
        ILogger<FcmPushService> logger)
    {
        _tokens = tokens;
        _options = options.Value;
        _logger = logger;
    }

    public async Task SendAppointmentNotificationAsync(Messages message, CancellationToken cancellationToken = default)
    {
        if (FirebaseApp.DefaultInstance is null)
        {
            _logger.LogDebug("FCM: Firebase не инициализирован (не указан CredentialPath), push пропущен");
            return;
        }

        var registrationTokens = await _tokens.GetTokensForUserAsync(message.UserId, cancellationToken);
        if (registrationTokens.Count == 0)
            return;

        var body = message.Content ?? string.Empty;
        var title = _options.NotificationTitle;
        var ts = DateTime.UtcNow.ToString("o");

        var data = new Dictionary<string, string>
        {
            ["id"] = message.Id.ToString(),
            ["message"] = body,
            ["timestamp"] = ts,
        };
        if (message.AppointmentId.HasValue)
            data["appointmentId"] = message.AppointmentId.Value.ToString();

        try
        {
            var multicast = new MulticastMessage
            {
                Tokens = registrationTokens.ToList(),
                Notification = new Notification
                {
                    Title = title,
                    Body = body,
                },
                Data = data,
                Android = new AndroidConfig
                {
                    Priority = Priority.High,
                },
                Apns = new ApnsConfig
                {
                    Headers = new Dictionary<string, string> { ["apns-priority"] = "10" },
                },
            };

            var response = await FirebaseMessaging.DefaultInstance.SendEachForMulticastAsync(multicast, cancellationToken);
            if (response.FailureCount > 0)
            {
                foreach (var sendResp in response.Responses.Where(r => !r.IsSuccess))
                {
                    _logger.LogWarning("FCM: ошибка отправки: {Error}", sendResp.Exception?.Message);
                }
            }

            _logger.LogInformation(
                "FCM: отправлено {Success}/{Total} пользователю {UserId}, сообщение {MessageId}",
                response.SuccessCount,
                registrationTokens.Count,
                message.UserId,
                message.Id);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "FCM: не удалось отправить push пользователю {UserId}", message.UserId);
        }
    }
}
