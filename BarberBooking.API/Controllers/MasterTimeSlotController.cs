using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.MasterTimeSlot.MasterTimeSlotCommands;
using BarberBooking.API.CQRS.MasterTimeSlotCommands;
using BarberBooking.API.CQRS.MasterTimeSlotCommands.Handler;
using BarberBooking.API.CQRS.MasterTimeSlotQueries;
using BarberBooking.API.Dto.DtoMasterTimeSlot;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberBooking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MasterTimeSlotController : ControllerBase
    {
        private readonly IMediator _mediator;
        public MasterTimeSlotController(IMediator mediator)
        {
            _mediator = mediator;
        }
        [Authorize]
        [HttpPost("create-timeSlot")]
        public async Task<IActionResult> CreateMasterTimeSlot([FromBody] DtoCreateMasterTimeSlot dtoCreateMasterTimeSlot)
        {
            var command = new MasterTimeSlotCreateAsyncCommand(dtoCreateMasterTimeSlot);
            var result = await _mediator.Send(command);
            if (result.IsFailure)
                return BadRequest(result.Error);
        
            return Ok(result.Value);
        }
        [Authorize]
        [HttpPost("create-timeSlots")]
        public async Task<IActionResult> CreateMasterTimeSlots([FromBody] List<DtoCreateMasterTimeSlot> dtoCreateMasterTimeSlot)
        {
            var command = new MasterTimeSlotCreateRangeAsyncCommand(dtoCreateMasterTimeSlot);
            var result = await _mediator.Send(command);
            if (result.IsFailure)
                return BadRequest(result.Error);
            
            return Ok(result.Value);
        }
        [Authorize]
        [HttpDelete("delete-timeSlot{Id}")]
        public async Task<IActionResult> DeleteMasterTimeSlot(Guid Id)
        {
            var command = new MasterTimeSlotDeleteAsyncCommand(Id);
            var result = await _mediator.Send(command);
            if (result.IsFailure)
                return BadRequest(result.Error);
    
            return Ok(result.Value);
        }
        [Authorize]
        [HttpPatch("update-timeSlot{Id}")]
        public async Task<IActionResult> UpdateMasterTimeSlot(Guid Id)
        {
            var command = new MasterTimeSlotDeleteAsyncCommand(Id);
            var result = await _mediator.Send(command);
            if (result.IsFailure)
                return BadRequest(result.Error);
            
            return Ok(result);
        }
        [HttpGet("get-FindTimeSlot{masterId}")]
        public async Task<IActionResult> GetFindSlot(Guid masterId, [FromQuery] DateOnly date, [FromQuery] TimeOnly startTime)
        {
            var query = new FindSlotAsyncQuery(masterId,date, startTime);
            var result = await _mediator.Send(query);
             if(result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }
        [HttpGet("get-availableSlots/{masterId}")]
        public async Task<IActionResult> GetAvailableSlots(Guid masterId, [FromQuery] DateOnly date, [FromQuery] TimeSpan serviceDuration)
        {
            var query = new GetAvailableSlotsAsyncQuery(masterId, date, serviceDuration);
            var result = await _mediator.Send(query);
             if(result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }
        [Authorize]
        [HttpGet("get-slotById{Id}")]
        public async Task<IActionResult> GetSlotById(Guid Id)
        {
            var query = new GetByIdAsyncQuery(Id);
            var result = await _mediator.Send(query);
             if(result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }
        [Authorize]
        [HttpGet("get-slotByMasterId{masterId}")]
        public async Task<IActionResult> GetByMasterId(Guid masterId, [FromQuery] DateOnly date)
        {
            var query = new GetByMasterAsyncQuery(masterId, date);
            var result = await _mediator.Send(query);
             if(result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);   
        }
        [Authorize]
        [HttpPost("timeSlot-createRangeByWeeklyTemplateHandler/{weeklyTemplateId}")]
        public async Task<IActionResult> TimeSlotCreateRangeByWeeklyTemplate(Guid weeklyTemplateId, [FromQuery] DateOnly dateFrom, [FromQuery] DateOnly dateTo)
        {
            var command = new TimeSlotCreateRangeByWeeklyTemplateCommand(weeklyTemplateId, dateFrom, dateTo);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);   
        }
    }
}