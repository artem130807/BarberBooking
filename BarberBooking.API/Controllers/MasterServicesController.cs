using System;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.MasterServices.MasterServicesCommands;
using BarberBooking.API.CQRS.MasterServices.MasterServicesQueries;
using BarberBooking.API.Dto.DtoMasterServices;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberBooking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MasterServicesController : ControllerBase
    {
        private readonly IMediator _mediator;

        public MasterServicesController(IMediator mediator)
        {
            _mediator = mediator;
        }

        [Authorize]
        [HttpPost("create-masterService")]
        public async Task<IActionResult> Create([FromBody] DtoCreateMasterService dto)
        {
            var result = await _mediator.Send(new CreateMasterServiceCommand(dto));
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }

        [Authorize]
        [HttpDelete("delete-masterService/{id}")]
        public async Task<IActionResult> Delete(Guid id)
        {
            var result = await _mediator.Send(new DeleteMasterServiceCommand(id));
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }

        [Authorize]
        [HttpGet("get-masterService/{id}")]
        public async Task<IActionResult> GetById(Guid id)
        {
            var result = await _mediator.Send(new GetMasterServiceByIdQuery(id));
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }

        [Authorize]
        [HttpGet("get-masterService-by-master/{masterProfileId}")]
        public async Task<IActionResult> GetByMasterProfile(Guid masterProfileId)
        {
            var result = await _mediator.Send(new GetMasterServicesByMasterProfileQuery(masterProfileId));
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }

        [AllowAnonymous]
        [HttpGet("get-services-for-booking-by-master/{masterProfileId:guid}")]
        public async Task<IActionResult> GetServicesForBookingByMaster(Guid masterProfileId)
        {
            var result = await _mediator.Send(new GetMasterServicesForBookingQuery(masterProfileId));
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
    }
}
