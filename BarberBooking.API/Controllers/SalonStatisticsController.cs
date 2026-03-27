using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.SalonStatisctic.Queries;
using BarberBooking.API.Filters.Salon;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberBooking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SalonStatisticsController : ControllerBase
    {
        private readonly IMediator _mediator;
        public SalonStatisticsController(IMediator mediator)
        {
            _mediator = mediator;
        }
        [HttpGet("GetSalonStatistics")]
        public async Task<IActionResult> GetSalonStatistics([FromQuery] SalonStatisticsFilter filter)
        {
            var query = new GetSalonStatisticsQuery(filter);
            var result = await _mediator.Send(query);
            if (result.IsFailure)
            {
                return BadRequest(result.Error);
            }
            return Ok(result.Value);
        }
        [Authorize("Admin")]
        [HttpGet("GetSalonStatisticWeek")]
        public async Task<IActionResult> GetSalonStatisticWeek([FromQuery] Guid salonId, [FromQuery] SalonStatisticsParams statisticsParams)
        {
            var query = new GetSalonStatisticsWeekQuery(salonId, statisticsParams);
            var result = await _mediator.Send(query);
            if (result.IsFailure)
            {
                return BadRequest(result.Error);
            }
            return Ok(result.Value);
        }
        [Authorize("Admin")]
        [HttpGet("GetSalonStatisticMounth")]
        public async Task<IActionResult> GetSalonStatisticMounth([FromQuery] Guid salonId, [FromQuery] int mounth, [FromQuery] DateOnly date)
        {
            var query = new GetSalonStatisticsMounthQuery(salonId, mounth, date);
            var result = await _mediator.Send(query);
            if (result.IsFailure)
            {
                return BadRequest(result.Error);
            }
            return Ok(result.Value);
        }
        [Authorize("Admin")]
        [HttpGet("GetSalonStatisticYear")]
        public async Task<IActionResult> GetSalonStatisticYear([FromQuery] Guid salonId, [FromQuery] DateOnly date)
        {
            var query = new GetSalonStatisticYearQuery(salonId, date);
            var result = await _mediator.Send(query);
            if (result.IsFailure)
            {
                return BadRequest(result.Error);
            }
            return Ok(result.Value);
        }
    }
}