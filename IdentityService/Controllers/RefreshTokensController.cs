using IdentityService.CQRS.RefreshTokens.Commands;
using IdentityService.Dto;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace IdentityService.Controllers;

[ApiController]
[Route("api/[controller]")]
public class RefreshTokensController : ControllerBase
{
    private readonly IMediator _mediator;

    public RefreshTokensController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpPost("RefreshAccessToken")]
    [AllowAnonymous]
    public async Task<IActionResult> RefreshAccessToken([FromBody] RefreshAccessTokenRequest body)
    {
        if (body == null || string.IsNullOrWhiteSpace(body.RefreshToken) || string.IsNullOrWhiteSpace(body.Devices))
            return BadRequest();

        var result = await _mediator.Send(new RefreshAccessTokenCommand(body.RefreshToken.Trim(), body.Devices.Trim()));
        if (result.IsFailure)
            return Unauthorized(new { message = result.Error });

        return Ok(result.Value);
    }
}
