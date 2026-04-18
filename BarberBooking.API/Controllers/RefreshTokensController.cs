using System;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.RefreshTokens.Commands;
using BarberBooking.API.CQRS.RefreshTokens.Queries;
using BarberBooking.API.Dto.DtoAuthorization;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberBooking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class RefreshTokensController:ControllerBase
    {
        private readonly IMediator _mediator;
        public RefreshTokensController(IMediator mediator)
        {
            _mediator = mediator;
        }
        [HttpGet("GetRefreshTokens")]
        public async Task<IActionResult> GetRefreshTokens()
        {
            var query = new GetRefreshTokensByUserQueries();
            var result = await  _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("GetRefreshTokensForUser/{userId:guid}")]
        public async Task<IActionResult> GetRefreshTokensForUser(Guid userId)
        {
            var result = await _mediator.Send(new GetRefreshTokensByUserIdForAdminQuery(userId));
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpPatch("RevokedRefreshToken/{Id}")]
        public async Task<IActionResult> RevokedRefreshToken(Guid Id)
        {
            var command = new RevokedRefreshTokenCommand(Id);
            var result = await  _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpPatch("RevokedRefreshTokens")]
        public async Task<IActionResult> RevokedRefreshTokens()
        {
            var command = new RevokedRefreshTokensCommand();
            var result = await  _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpPatch("RevokedRefreshTokensForUser/{userId:guid}")]
        public async Task<IActionResult> RevokedRefreshTokensForUser(Guid userId)
        {
            var result = await _mediator.Send(new RevokedRefreshTokensForUserCommand(userId));
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("IsRevokedRefreshToken")]
        [AllowAnonymous]
        public async Task<IActionResult> IsRevokedRefreshToken([FromQuery] string token)
        {
            if (string.IsNullOrWhiteSpace(token))
                return BadRequest();
            var result = await _mediator.Send(new IsRevokedRefreshTokenQuery(token));
            return Ok(result);
        }

        [HttpPost("RefreshAccessToken")]
        [AllowAnonymous]
        public async Task<IActionResult> RefreshAccessToken([FromBody] RefreshAccessTokenRequest body)
        {
            if (body == null || string.IsNullOrWhiteSpace(body.RefreshToken) ||
                string.IsNullOrWhiteSpace(body.Devices))
                return BadRequest();
            var result = await _mediator.Send(
                new RefreshAccessTokenCommand(body.RefreshToken.Trim(), body.Devices.Trim()));
            if (result.IsFailure)
                return Unauthorized(new { message = result.Error });
            return Ok(result.Value);
        }
    }
}