using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;
using NotifyService.Application.Contracts;
using NotifyService.Application.Dto.DtoAuthorization;

namespace NotifyService.API.Controllers;

[ApiController]
[Route("api/users")]
public sealed class UsersEmailController : ControllerBase
{
    private readonly IEmailVerficationService _verificationService;
    private readonly IMemoryCache _cache;

    public UsersEmailController(IEmailVerficationService verificationService, IMemoryCache cache)
    {
        _verificationService = verificationService;
        _cache = cache;
    }

    [HttpPost("send-verification")]
    public async Task<IActionResult> SendVerificationCode([FromBody] SendVerificationRequest verificationRequest)
    {
        var result = await _verificationService.SendVerificationAsync(verificationRequest.Email);
        if (result.IsFailure)
            return BadRequest(result.Error);
        return Ok(result.Value);
    }

    [HttpPost("verify-email")]
    public async Task<IActionResult> VerifyCode([FromBody] VerifyCodeRequest request)
    {
        var cacheKey = $"verification_{request.Code}";
        if (!_cache.TryGetValue(cacheKey, out string? email) || string.IsNullOrEmpty(email))
            return BadRequest("РљРѕРґ РЅРµ РЅР°Р№РґРµРЅ РёР»Рё СѓСЃС‚Р°СЂРµР»");

        var result = await _verificationService.Verificate(request.Code, email);
        if (result.IsFailure)
            return BadRequest(new { error = result.Error });

        _cache.Remove(cacheKey);
        return Ok(result.Value);
    }
}
