using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using NotifyService.Application.Contracts;
using NotifyService.Domain.Models;

namespace NotifyService.Infrastructure.Push;

public class FcmPushService : IFcmPushService
{
    private readonly IUserFcmTokenRepository _tokens;
    private readonly FirebasePushOptions _options;
    private readonly ILogger<FcmPushService> _logger;

    public FcmPushService(IUserFcmTokenRepository tokens,
        IOptions<FirebasePushOptions> options,
        ILogger<FcmPushService> logger)
    {
        _tokens = tokens;
        _options = options.Value;
        _logger = logger;
    }

    public async Task SendAppointmentNotificationAsync(PushAppointmentNotification message,
        CancellationToken cancellationToken = default)
    {
        if (FirebaseApp.DefaultInstance is null)
        {
            _logger.LogDebug("FCM: Firebase РЅРµ РёРЅРёС†РёР°Р»РёР·РёСЂРѕРІР°РЅ, push РїСЂРѕРїСѓС‰РµРЅ");
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
            ["timestamp"] = ts
        };

        if (message.AppointmentId.HasValue)
            data["appointmentId"] = message.AppointmentId.Value.ToString();

        try
        {
            var multicast = new MulticastMessage
            {
                Tokens = registrationTokens.ToList(),
                Notification = new Notification { Title = title, Body = body },
                Data = data,
                Android = new AndroidConfig { Priority = Priority.High },
                Apns = new ApnsConfig
                {
                    Headers = new Dictionary<string, string> { ["apns-priority"] = "10" }
                }
            };

            var response = await FirebaseMessaging.DefaultInstance.SendEachForMulticastAsync(multicast, cancellationToken);
            if (response.FailureCount > 0)
            {
                foreach (var sendResp in response.Responses.Where(r => !r.IsSuccess))
                {
                    _logger.LogWarning("FCM РѕС€РёР±РєР° РѕС‚РїСЂР°РІРєРё: {Error}", sendResp.Exception?.Message);
                }
            }

            _logger.LogInformation(
                "FCM: РѕС‚РїСЂР°РІР»РµРЅРѕ {Success}/{Total} СЃРѕРѕР±С‰РµРЅРёР№ РїРѕР»СЊР·РѕРІР°С‚РµР»СЋ {UserId}, messageId={MessageId}",
                response.SuccessCount,
                registrationTokens.Count,
                message.UserId,
                message.Id);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "FCM: РѕС€РёР±РєР° РїСЂРё РѕС‚РїСЂР°РІРєРµ push РїРѕР»СЊР·РѕРІР°С‚РµР»СЋ {UserId}", message.UserId);
        }
    }
}
