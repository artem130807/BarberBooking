using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.EmailContracts;
using BarberBooking.API.CQRS.Commands;
using BarberBooking.API.CQRS.Queries;
using BarberBooking.API.CQRS.Users.QueriesUser;
using BarberBooking.API.Dto.DtoAuthorization;
using BarberBooking.API.Dto.DtoUsers;
using MediatR;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ActionConstraints;
using Microsoft.Extensions.Caching.Memory;
using Serilog;

namespace BarberBooking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UsersController : ControllerBase
    {
        private readonly IEmailVerficationService _verificationService;
        private readonly IMemoryCache _cache;
        private readonly IMediator _mediator;
        private readonly IAuthCookieService _cookieService;
        public UsersController(IMediator mediator, IEmailVerficationService verificationService, IMemoryCache cache, IAuthCookieService cookieService)
        {
            _mediator = mediator;
            _verificationService = verificationService;
            _cache = cache;
            _cookieService = cookieService;
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
            if (!_cache.TryGetValue(cacheKey, out string email) || string.IsNullOrEmpty(email))
                return BadRequest("Код ненайден или устарел");
            
            var result = await _verificationService.Verificate(request.Code, email);
            if (result.IsFailure)
                return BadRequest(new { error = result.Error });
            _cache.Remove(cacheKey);
            return Ok(result.Value);
        }
        [HttpPost("RegisterUser")]
        public async Task<IActionResult> Register([FromBody] DtoCreateUser dtoCreateUser)
        {
            var comamnd = new RegisterUserCommand(dtoCreateUser);
            var result = await _mediator.Send(comamnd);
            if (result.IsFailure)
                return BadRequest(new { error = result.Error });
            _cookieService.SetAuthCookie(Response, result.Value.Token);
            await _verificationService.DeleteEmailVerificate(comamnd.dtoCreateUser.Email);         
            return Ok(result.Value);
        }
        [HttpPost("LoginUser")]
        public async Task<IActionResult> Login([FromBody] DtoLoginUser login)
        {
            var query = new LoginUserQuery(login.Email, login.PasswordHash);
            var result = await _mediator.Send(query);
            if (result.IsFailure)
                return BadRequest(new { error = result.Error });
            _cookieService.SetAuthCookie(Response, result.Value.Token);
            return Ok(result.Value);
        }
        [HttpPatch("updatePassword")]
        public async Task<IActionResult> UpdatePassword([FromBody] DtoUpdatePassword dtoUpdatePassword)
        {
            var command = new UpdatePasswordHashCommand(dtoUpdatePassword);     
            var result = await _mediator.Send(command);
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("get-user-by-token-id")]
        public async Task<IActionResult> GetUserByTokenId()
        {
            var command = new GetUserByTokenIdQuery();     
            var result = await _mediator.Send(command);
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpPatch("updateCity")]
        public async Task<IActionResult> UpdateCity([FromQuery] string city)
        {
            var command = new UpdateCityCommand(city);     
            var result = await _mediator.Send(command);
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("get_cities")]
        public async Task<IActionResult> GetCities([FromQuery] string city)
        {
            var command = new GetUserCitiesQuery(city);     
            var result = await _mediator.Send(command);
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("get_user_profile/{Id}")]
        public async Task<IActionResult> GetUserProfileById(Guid Id)
        {
            var command = new GetUserProfileByIdQuery(Id);     
            var result = await _mediator.Send(command);
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
    }
}