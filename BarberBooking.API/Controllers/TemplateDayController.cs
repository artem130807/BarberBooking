using System;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.TemplateDay.Commands;
using BarberBooking.API.CQRS.TemplateDay.Queries;
using BarberBooking.API.Dto.DtoTemplateDay;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberBooking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class TemplateDayController : ControllerBase
    {
        private readonly IMediator _mediator;

        public TemplateDayController(IMediator mediator)
        {
            _mediator = mediator;
        }

        [HttpGet("get-template-day/{id:guid}")]
        public async Task<IActionResult> GetTemplateDay(Guid id)
        {
            var query = new GetTemplateDayQuery(id);
            var result = await _mediator.Send(query);
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }

        [HttpGet("get-template-days/{weeklyTemplateId:guid}")]
        public async Task<IActionResult> GetTemplateDays(Guid weeklyTemplateId)
        {
            var query = new GetTemplateDaysQuery(weeklyTemplateId);
            var result = await _mediator.Send(query);
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }

        [HttpPost("create-template-day")]
        public async Task<IActionResult> CreateTemplateDay([FromBody] DtoCreateTemplateDay dto)
        {
            var command = new CreateTemplateDayCommand(dto);
            var result = await _mediator.Send(command);
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }

        [HttpPatch("update-template-day/{id:guid}")]
        public async Task<IActionResult> UpdateTemplateDay(Guid id, [FromBody] DtoUpdateTemplateDay dto)
        {
            var command = new UpdateTemplateDayCommand(id, dto);
            var result = await _mediator.Send(command);
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }

        [HttpDelete("delete-template-day/{id:guid}")]
        public async Task<IActionResult> DeleteTemplateDay(Guid id)
        {
            var command = new DeleteTemplateDayCommand(id);
            var result = await _mediator.Send(command);
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
    }
}
