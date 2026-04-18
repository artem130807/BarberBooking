using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.FcmPushContracts;
using BarberBooking.API.Dto.DtoPush;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberBooking.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class PushNotificationsController : ControllerBase
{
    private readonly IUserContext _userContext;
    private readonly IUserFcmTokenRepository _fcmTokens;

    public PushNotificationsController(IUserContext userContext, IUserFcmTokenRepository fcmTokens)
    {
        _userContext = userContext;
        _fcmTokens = fcmTokens;
    }

    /// <summary>Зарегистрировать или обновить FCM-токен текущего пользователя (то же устройство может быть только у одного пользователя).</summary>
    [HttpPost("fcm-token")]
    public async Task<IActionResult> RegisterFcmToken([FromBody] DtoFcmTokenRequest request,
        CancellationToken cancellationToken)
    {
        if (!ModelState.IsValid || string.IsNullOrWhiteSpace(request?.Token))
            return BadRequest("Токен обязателен");

        await _fcmTokens.UpsertTokenAsync(_userContext.UserId, request.Token, cancellationToken);
        return Ok();
    }

    /// <summary>Отвязать устройство (например, при выходе из аккаунта на этом устройстве).</summary>
    [HttpDelete("fcm-token")]
    public async Task<IActionResult> UnregisterFcmToken([FromBody] DtoFcmTokenRequest request,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request?.Token))
            return BadRequest("Токен обязателен");

        await _fcmTokens.RemoveTokenAsync(_userContext.UserId, request.Token, cancellationToken);
        return Ok();
    }
}
