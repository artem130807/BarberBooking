using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.Conversations;
using BarberBooking.API.CQRS.Conversations.Commands;
using BarberBooking.API.CQRS.Conversations.Queries;
using BarberBooking.API.Dto.DtoConversation;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.ConversationFilter;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace BarberBooking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ConversationController:ControllerBase
    {
        private readonly IMediator _mediator;
        public ConversationController(IMediator mediator)
        {
            _mediator = mediator;
        }
        [HttpPost("CreateConversation/{participant2Id}")]
        public async Task<IActionResult> Create(Guid participant2Id)
        {
            var command = new CreateConversationCommand(participant2Id);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpDelete("DeleteConversation/{Id}")]
        public async Task<IActionResult> Delete(Guid Id)
        {
            var command = new DeleteConversationCommand(Id);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("Get-Conversation/{Id}")]
        public async Task<IActionResult> GetConversation(Guid Id)
        {
            var query = new GetConversationQuery(Id);
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("Get-Conversations")]
        public async Task<IActionResult> GetConversations([FromQuery] PageParams pageParams)
        {
            var query = new GetConversationsQuery(pageParams);
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("Get-Conversations-By-Search")]
        public async Task<IActionResult> GetConversationsBySearch([FromQuery] SearchConversationFilter filter, [FromQuery] PageParams pageParams)
        {
            var query = new GetConversationsBySearchQuery(filter ,pageParams);
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
    }
}