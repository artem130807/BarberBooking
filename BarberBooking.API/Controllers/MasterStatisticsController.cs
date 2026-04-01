using System;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.MasterStatistic.Queries;
using BarberBooking.API.Filters.Master;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberBooking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MasterStatisticsController : ControllerBase
    {
        private readonly IMediator _mediator;

        public MasterStatisticsController(IMediator mediator)
        {
            _mediator = mediator;
        }

        [Authorize("Admin")]
        [HttpGet("GetMasterStatisticWeek")]
        public async Task<IActionResult> GetMasterStatisticWeek(
            [FromQuery] Guid masterProfileId,
            [FromQuery] MasterStatisticsParams statisticsParams)
        {
            var query = new GetMasterStatisticsWeekQuery(masterProfileId, statisticsParams);
            var result = await _mediator.Send(query);
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }

        [Authorize("Admin")]
        [HttpGet("GetMasterStatisticMounth")]
        public async Task<IActionResult> GetMasterStatisticMounth(
            [FromQuery] Guid masterProfileId,
            [FromQuery] int mounth,
            [FromQuery] DateOnly date)
        {
            var query = new GetMasterStatisticsMounthQuery(masterProfileId, mounth, date);
            var result = await _mediator.Send(query);
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }

        [Authorize("Admin")]
        [HttpGet("GetMasterStatisticYear")]
        public async Task<IActionResult> GetMasterStatisticYear([FromQuery] Guid masterProfileId, [FromQuery] DateOnly date)
        {
            var query = new GetMasterStatisticYearQuery(masterProfileId, date);
            var result = await _mediator.Send(query);
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
    }
}
