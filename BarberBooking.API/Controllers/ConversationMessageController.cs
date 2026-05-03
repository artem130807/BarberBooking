using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.ConversationMessages.Commands;
using BarberBooking.API.CQRS.ConversationMessages.Queries;
using BarberBooking.API.Dto.DtoConversationMessages;
using BarberBooking.API.Filters;
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
        [HttpDelete("Delete-message/{Id}")]
        public async Task<IActionResult> Delete(Guid Id)
        {
            var command = new DeleteConversationMessageCommand(Id);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpPatch("Update-Message")]
        public async Task<IActionResult> UpdatePatch(Guid Id, string content)
        {
            var command = new UpdateConversationMessageCommand(Id, content);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("Get-Message/{Id}")]
        public async Task<IActionResult> GetMessage(Guid Id)
        {
            var query = new GetConversationMessageQuery(Id);
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("Get-Messages/{conversationId}")]
        public async Task<IActionResult> GetMessages(Guid conversationId, [FromQuery] PageParams pageParams)
        {
            var query = new GetConversationMessagesQuery(conversationId, pageParams);
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("Get-UnreadMessages")]
        public async Task<IActionResult> GetMessages()
        {
            var query = new GetUnreadMessagesQuery();
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
    }
}