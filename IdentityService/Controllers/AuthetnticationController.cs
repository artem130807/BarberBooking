using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.InteropServices;
using System.Security.Claims;
using System.Security.Cryptography.X509Certificates;
using System.Threading.Tasks;
using IdentityService.Contracts;
using IdentityService.CQRS.Commands;
using IdentityService.CQRS.Queries;
using IdentityService.DtoModels;
using IdentityService.Models;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;

namespace IdentityService.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthetnticationController : ControllerBase
    {
        private readonly IEmailVerficationService _verificationService;
        private readonly IMemoryCache _cache;
        private readonly IMediator _mediator;

        public AuthetnticationController(IEmailVerficationService verficationService, IMemoryCache cache, IMediator mediator)
        {;
            _verificationService = verficationService;
            _cache = cache;
            _mediator = mediator;
        }
        [HttpPost("send-verification")]
        public async Task<IActionResult> SendVerificationCode([FromBody] SendVerificationRequest verificationRequest)
        {
            await _verificationService.SendVerificationAsync(verificationRequest.Email);
            return Ok("Новый код подтверждения");
        }
        [HttpPost("verify-email")]
        public async Task<IActionResult> VerifyCode([FromBody] VerifyCodeRequest request)
        {
            var cacheKey = $"verification_{request.Code}";
            if (!_cache.TryGetValue(cacheKey, out string email) || string.IsNullOrEmpty(email))
            {
                return BadRequest("Код ненайден или устарел");
            }
            var isValid = await _verificationService.Verificate(request.Code, email);
            if (!isValid)
            {
                return BadRequest("Неправильный код");
            }
            _cache.Remove(cacheKey);
            return Ok("Email подтвержден");
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register([FromBody] DtoUserRegister userRegister)
        {
            try
            {         
            var command = new RegisterUserCommand(userRegister.Name,userRegister.Email,userRegister.PasswordHash,userRegister.City);      
            var result = await _mediator.Send(command);
            Response.Cookies.Append("tasty", result.Token, new CookieOptions
            {
                HttpOnly = true,
                Secure = true,
                SameSite = SameSiteMode.Strict,
                Expires = DateTime.UtcNow.AddHours(12)
            });
            await _verificationService.DeleteEmailVerificate(command.Email);         
            return Ok(result);      
            }catch(Exception ex)
            {
                return BadRequest(ex.Message);
            }      
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] DtoUserLoginRequest dtoUserLoginRequest)
        {
                var query = new LoginUserQuery( dtoUserLoginRequest.Email, dtoUserLoginRequest.PasswordHash);
                var token = await _mediator.Send(query);
                Response.Cookies.Append("tasty", token.Token, new CookieOptions
                {
                    HttpOnly = true,
                    Secure = true,
                    SameSite = SameSiteMode.Strict,
                    Expires = DateTime.UtcNow.AddHours(12)
                });
                return Ok(token);
          
        }
        [Authorize]
        [HttpPatch("updatePassword")]
        public async Task<IActionResult> UpdatePassword(string email, string password)
        {
            try
            {
                var command = new UpdatePasswordHashCommand(email, password);     
                await _mediator.Send(command);
                return Ok("Успешно");
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }
        [Authorize]
        [HttpPatch("updateCity")]
        public async Task<IActionResult> UpdateCity(string City)
        {
            try
            {
                var userId = Guid.Parse(User.FindFirstValue("userId"));
                var command = new UpdateCityCommand(userId, City);
                var updateCity = await _mediator.Send(command);
                return Ok(updateCity);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }          
        }
        [HttpGet("{Id:guid}")]
        public async Task<IActionResult> GetUserById(Guid Id)
        {
            var command = new GetUserByIdQuery(Id);
            var result = await _mediator.Send(command);
            return Ok(result);
        }

    }
}