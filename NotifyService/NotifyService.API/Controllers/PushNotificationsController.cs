using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using NotifyService.Application.Contracts;
using NotifyService.Application.Dto.DtoPush;

namespace NotifyService.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public sealed class PushNotificationsController : ControllerBase
{
    private readonly IUserContext _userContext;
    private readonly IUserFcmTokenRepository _fcmTokens;

    public PushNotificationsController(IUserContext userContext, IUserFcmTokenRepository fcmTokens)
    {
        _userContext = userContext;
        _fcmTokens = fcmTokens;
    }

    [HttpPost("fcm-token")]
    public async Task<IActionResult> RegisterFcmToken([FromBody] DtoFcmTokenRequest request,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request?.Token))
            return BadRequest("РќРµ СѓРєР°Р·Р°РЅ С‚РѕРєРµРЅ");

        await _fcmTokens.UpsertTokenAsync(_userContext.UserId, request.Token, cancellationToken);
        return Ok();
    }

    [HttpDelete("fcm-token")]
    public async Task<IActionResult> UnregisterFcmToken([FromBody] DtoFcmTokenRequest request,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request?.Token))
            return BadRequest("РќРµ СѓРєР°Р·Р°РЅ С‚РѕРєРµРЅ");

        await _fcmTokens.RemoveTokenAsync(_userContext.UserId, request.Token, cancellationToken);
        return Ok();
    }
}
