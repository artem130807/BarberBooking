using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.Messages.Commands;
using BarberBooking.API.CQRS.Messages.Queries;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberBooking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class MessageController : ControllerBase
    {
        private readonly IMediator _mediator;
        public MessageController(IMediator mediator)
        {
            _mediator = mediator;
        }
        [HttpGet("get-messages")]
        public async Task<IActionResult> GetMessages()
        {
            var query = new GetMessagesQuery();
            var result = await _mediator.Send(query);
            if (result.IsFailure)
                return BadRequest(result.Error);
            
            return Ok(result.Value);
        }
        [HttpGet("get-unread-count-messages")]
        public async Task<IActionResult> GetUnreadMessages()
        {
            var query = new GetCountMessagesQuery();
            var result = await _mediator.Send(query);
            if (result.IsFailure)
                return BadRequest(result.Error);
            
            return Ok(result.Value);
        }
        [HttpDelete("delete-message/{Id}")]
        public async Task<IActionResult> DeleteMessage(Guid Id)
        {
            var command = new DeleteMessageCommand(Id);
            var result = await _mediator.Send(command);
            if (result.IsFailure)
                return BadRequest(result.Error);
            
            return Ok(result.Value);
        }
    }
}
