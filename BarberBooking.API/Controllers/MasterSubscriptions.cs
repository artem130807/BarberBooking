using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.AppointmentsCommands;
using BarberBooking.API.CQRS.MasterSubscription.MasterSubscriptionCommands;
using BarberBooking.API.CQRS.MasterSubscription.MasterSubscriptionQueries;
using BarberBooking.API.Dto.DtoMasterSubscription;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace BarberBooking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MasterSubscriptions : ControllerBase
    {
        private readonly IMediator _mediator;
        public MasterSubscriptions(IMediator mediator)
        {
            _mediator = mediator;
        }
        [HttpPost("Create-MasterSubscription")]
        public async Task<IActionResult> CreateMasterSubscription([FromBody] DtoCreateMasterSubscription dtoCreateMasterSubscription)
        {
            var command = new CreateMasterSubscriptionCommand(dtoCreateMasterSubscription);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpDelete("Delete-MasterSubscription/{Id}")]
        public async Task<IActionResult> DeleteMasterSubscription(Guid Id)
        {
            var command = new DeleteMasterSubscriptionCommand(Id);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("Get-MasterSubscription{Id}")]
        public async Task<IActionResult> GetMasterSubscriptionById(Guid Id)
        {
            var query = new GetMasterSubscriptionByIdQuery(Id);
            var result = await _mediator.Send(query);
             if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("Get-MasterSubscriptions")]
        public async Task<IActionResult> GetMasterSubscriptions()
        {
            var query = new GetMasterSubscriptionsQuery();
            var result = await _mediator.Send(query);
             if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
    }
}