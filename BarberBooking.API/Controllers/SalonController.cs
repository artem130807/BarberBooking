using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.Salon.Queries;
using BarberBooking.API.CQRS.Salon.Queries.Handlers;
using BarberBooking.API.CQRS.Salons.Commands;
using BarberBooking.API.Dto.DtoSalons;
using BarberBooking.API.Filters;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace BarberBooking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SalonController : ControllerBase
    {
        private readonly IMediator _mediator;
        public SalonController(IMediator mediator)
        {
            _mediator = mediator;
        }
        [HttpPost("CreateSalon")]
        public async Task<IActionResult> CreateSalon([FromBody] DtoCreateSalon dtoCreateSalon)
        {
            var command = new CreateSalonCommand(dtoCreateSalon);
            var result = await _mediator.Send(command);
            if (result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }
        [HttpDelete("DeleteSalon{Id}")]
        public async Task<IActionResult> DeleteSalon(Guid Id)
        {
            var command = new DeleteSalonCommand(Id);
            var result = await _mediator.Send(command);
            if (result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }
        [HttpPatch("UpdateSalon{Id}")]
        public async Task<IActionResult> UpdateSalon(Guid Id, [FromBody] DtoUpdateSalon dtoUpdateSalon)
        {
            var command = new UpdateSalonCommand(Id, dtoUpdateSalon);
            var result = await _mediator.Send(command);
            if (result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }
        [HttpGet("GetSalons")]
        public async Task<IActionResult>  GetSalons()
        {
            var query = new GetSalonsQuery();
            var result = await _mediator.Send(query);
            if (result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }
        [HttpGet("GetActiveSalons")]
        public async Task<IActionResult>  GetActiveSalons()
        {
            var query = new GetActiveSalonsQuery();
            var result = await _mediator.Send(query);
            if (result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }
        [HttpGet("GetSalonById{Id}")]
        public async Task<IActionResult>  GetsalonById(Guid Id)
        {
            var query = new GetSalonByIdQuery(Id);
            var result = await _mediator.Send(query);
            if (result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }
        [HttpGet("GetSalonsName")]
        public async Task<IActionResult>  GetNameSalons([FromQuery] string name)
        {
            var query = new GetSalonsNameStartWithQuery(name);
            var result = await _mediator.Send(query);
            if (result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }
        [HttpGet("GetSalonsByFilter")]
        public async Task<IActionResult> GetSalonsByFilter([FromQuery] SalonFilter salonFilter)
        {
            var query = new GetSalonsByFilterQuery(salonFilter);
            var result = await _mediator.Send(query);
            if (result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }
    }
}