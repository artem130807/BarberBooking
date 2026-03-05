using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.MasterProfile.Commands;
using BarberBooking.API.CQRS.MasterProfile.Queries;
using BarberBooking.API.CQRS.MasterProfiles.Queries;
using BarberBooking.API.Dto.DtoMasterProfile;
using BarberBooking.API.Filters.MasterProfile;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace BarberBooking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MasterProfileController : ControllerBase
    {
        private readonly IMediator _mediator;
        public MasterProfileController(IMediator mediator)
        {
            _mediator = mediator;
        }
        [HttpPost("CreateMasterProfile")]
        public async Task<IActionResult> CreateMasterProfile([FromBody] DtoCreateMasterProfile dtoCreateMasterProfile)
        {
            var command = new CreateMasterProfileCommand(dtoCreateMasterProfile);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }
        [HttpDelete("DeleteMasterProfile{Id}")]
        public async Task<IActionResult> DeleteMasterProfile(Guid Id)
        {
            var command = new DeleteMasterProfileCommand(Id);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }
        [HttpPatch("UpdateMasterProfile{Id}")]
        public async Task<IActionResult> UpdateMasterProfile(Guid Id, [FromBody] DtoUpdateMasterProfile dtoUpdateMasterProfile)
        {
            var command = new UpdateMasterProfileCommand(Id ,dtoUpdateMasterProfile);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }
        [HttpGet("GetMasterProfileById/{Id}")]
        public async Task<IActionResult> GetMasterProfileById(Guid Id)
        {
            var query = new GetMasterProfileByIdQuery(Id);
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }
        [HttpGet("GetMastersBySalon/{salonId}")]
        public async Task<IActionResult> GetMastersBySalon(Guid salonId)
        {
            var query = new GetMastersBySalonQuery(salonId);
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }
        [HttpGet("GetMastersBySalonFilter{salonId}")]
        public async Task<IActionResult> GetMastersBySalonFilter(Guid salonId, [FromQuery] MasterProfileFilter filter)
        {
            var query = new GetMastersBySalonFilterQuery(salonId, filter);
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }
        [HttpGet("GetTheBestMasters")]
        public async Task<IActionResult> GetTheBestMasters([FromQuery] int take)
        {
            var query = new GetTheBestMastersQuery(take);
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }

    }
}