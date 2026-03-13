using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.Services.ServicesQueries;
using BarberBooking.API.CQRS.ServicesCommands;
using BarberBooking.API.CQRS.ServicesQueries;
using BarberBooking.API.Dto.DtoServices;
using BarberBooking.API.Filters;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace BarberBooking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ServicesController : ControllerBase
    {
        private readonly IMediator _mediator;
        public ServicesController(IMediator mediator)
        {
            _mediator = mediator;
        }
        [HttpPost("create-service")]
        public async Task<IActionResult> CreateService([FromBody] DtoCreateServices dtoCreateServices)
        {
            var command = new ServicesCreateAsyncCommand(dtoCreateServices);
            var result = await _mediator.Send(command);
            return Ok(result);
        }
        [HttpDelete("delete-service{Id}")]
        public async Task<IActionResult> DeleteService(Guid Id)
        {
            var command = new ServicesDeleteAsyncCommand(Id);
            var result = await _mediator.Send(command);
            return Ok(result);
        }
        [HttpPatch("update-service{Id}")]
        public async Task<IActionResult> UpdateService(Guid Id, [FromBody] DtoUpdateServices dtoUpdateServices)
        {
            var command = new ServicesUpdateAsyncCommand(Id, dtoUpdateServices);
            var result = await _mediator.Send(command);
            return Ok(result);
        }
        [HttpGet("get-active-servicesByActiveSalon{salonId}")]
        public async Task<IActionResult> GetActiveServicesBySalon(Guid salonId)
        {
            var query = new GetActiveBySalonAsyncQuery(salonId);
            var result = await _mediator.Send(query);
            return Ok(result);
        }
        [HttpGet("get-serviceById{Id}")]
        public async Task<IActionResult> GetServiceById(Guid Id)
        {
            var query = new GetByIdAsyncQuery(Id);
            var result = await _mediator.Send(query);
            return Ok(result);
        }
        [HttpGet("get-serviceBySalon/{salonId}")]
        public async Task<IActionResult> GetServicesBySalon(Guid salonId)
        {
            var query = new GetBySalonAsyncQuery(salonId);
            var result = await _mediator.Send(query);
            return Ok(result);
        }
        [HttpGet("get-services-by-startWith")]
         public async Task<IActionResult> GetServicesByStartWith([FromQuery] string name, [FromQuery] PageParams pageParams)
        {
            var query = new GetServicesNameStartWithQuery(name, pageParams);
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }
    }
}