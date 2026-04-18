using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.SalonsAdmins.Queries;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberBooking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SalonAdminController:ControllerBase
    {
        private readonly IMediator _mediator;
        public SalonAdminController(IMediator mediator)
        {
            _mediator = mediator;
        }
        [Authorize("Admin")]
        [HttpGet("GetSalonsAdmin")]
        public async Task<IActionResult> GetSalonsAdmin()
        {
            var query = new GetSalonsAdminsQuery();
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
    }
}