using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.SalonStatisctic.Queries;
using BarberBooking.API.Filters.Salon;
using MediatR;
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
    }
}