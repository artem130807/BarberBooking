using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.ConversationMessages.Commands;
using BarberBooking.API.Dto.DtoConversationMessages;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace BarberBooking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ConversationMessageController : ControllerBase
    {
        private readonly IMediator _mediator;
        public ConversationMessageController(IMediator mediator)
        {
            _mediator = mediator;
        }
        [HttpGet("Create-message")]
        public async Task<IActionResult> Create(DtoCreateConversationMessage dtoCreateConversationMessage)
        {
            var command = new CreateConversationMessageCommand(dtoCreateConversationMessage);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
    }
}