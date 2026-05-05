using IdentityService.Application.CQRS.Users.Commands;
using IdentityService.Application.CQRS.Users.Queries;
using IdentityService.Application.Dto.Users;
using IdentityService.Infrastructure.Auth;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace IdentityService.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IMediator _mediator;
    private readonly IAuthCookieService _cookieService;

    public UsersController(IMediator mediator, IAuthCookieService cookieService)
    {
        _mediator = mediator;
        _cookieService = cookieService;
    }

    [HttpPost("RegisterUser")]
    public async Task<IActionResult> Register([FromBody] DtoCreateUser dtoCreateUser)
    {
        var command = new RegisterUserCommand(dtoCreateUser);
        var result = await _mediator.Send(command);
        if (result.IsFailure)
            return BadRequest(new { error = result.Error });

        _cookieService.SetAuthCookie(Response, result.Value.AccessToken);
        return Ok(result.Value);
    }

    [HttpPost("LoginUser")]
    public async Task<IActionResult> Login([FromBody] DtoLoginUser login)
    {
        var query = new LoginUserQuery(login.Email, login.PasswordHash, login.Devices);
        var result = await _mediator.Send(query);
        if (result.IsFailure)
            return BadRequest(new { error = result.Error });

        _cookieService.SetAuthCookie(Response, result.Value.AccessToken);
        return Ok(result.Value);
    }

    [Authorize]
    [HttpPatch("updatePassword")]
    public async Task<IActionResult> UpdatePassword([FromBody] DtoUpdatePassword dtoUpdatePassword)
    {
        var result = await _mediator.Send(new UpdatePasswordHashCommand(dtoUpdatePassword));
        if (result.IsFailure) return BadRequest(result.Error);
        return Ok(result.Value);
    }

    [Authorize]
    [HttpGet("get-user-by-token-id")]
    public async Task<IActionResult> GetUserByTokenId()
    {
        var result = await _mediator.Send(new GetUserByTokenIdQuery());
        if (result.IsFailure) return BadRequest(result.Error);
        return Ok(result.Value);
    }

    [Authorize]
    [HttpPatch("updateCity")]
    public async Task<IActionResult> UpdateCity([FromQuery] string city, [FromQuery] string devices)
    {
        var result = await _mediator.Send(new UpdateCityCommand(city, devices));
        if (result.IsFailure) return BadRequest(result.Error);
        return Ok(result.Value);
    }

    [HttpGet("get_cities")]
    public async Task<IActionResult> GetCities([FromQuery] string city)
    {
        var result = await _mediator.Send(new GetUserCitiesQuery(city));
        if (result.IsFailure) return BadRequest(result.Error);
        return Ok(result.Value);
    }

    [HttpGet("get_user_profile/{Id}")]
    public async Task<IActionResult> GetUserProfileById(Guid Id)
    {
        var result = await _mediator.Send(new GetUserProfileByIdQuery(Id));
        if (result.IsFailure) return BadRequest(result.Error);
        return Ok(result.Value);
    }
}
