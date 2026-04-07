using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.WeeklyTemplate.Commands;
using BarberBooking.API.CQRS.WeeklyTemplate.Queries;
using BarberBooking.API.Dto.DtoWeeklyTemplate;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberBooking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class WeeklyTemplateController : ControllerBase
    {
        private readonly IMediator _mediator;
        public WeeklyTemplateController(IMediator mediator)
        {
            _mediator = mediator;   
        }
        [HttpGet("get-weekly-template/{Id}")]
        public async Task<IActionResult> GetWeeklyTemplate(Guid Id)
        {
            var query = new GetWeeklyTemplateQuery(Id);
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("get-weekly-templates")]
        public async Task<IActionResult> GetWeeklyTemplates()
        {
            var query = new GetWeeklyTemplatesQuery();
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpPost("create-weekly-templates")]
        public async Task<IActionResult> GetWeeklyTemplates([FromBody] DtoCreateWeeklyTemplate dtoCreateWeeklyTemplate)
        {
            var query = new CreateWeeklyTemplateCommand(dtoCreateWeeklyTemplate);
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpDelete("delete-weekly-templates/{Id}")]
        public async Task<IActionResult> DeleteWeeklyTemplates(Guid Id)
        {
            var query = new DeleteWeeklyTemplateCommand(Id);
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
    }
}