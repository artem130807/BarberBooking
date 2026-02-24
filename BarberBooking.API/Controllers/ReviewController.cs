using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.Reviews.Command;
using BarberBooking.API.Dto.DtoReview;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace BarberBooking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ReviewController : ControllerBase
    {
        private readonly IMediator _mediator;
        public ReviewController(IMediator mediator)
        {
            _mediator = mediator;
        }
        [HttpPost("Create-Review")]
        public async Task<IActionResult> CreateReview([FromBody] DtoCreateReview dtoCreateReview)
        {
            var command = new CreateReviewCommand(dtoCreateReview);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpDelete("Delete-Review{Id}")]
        public async Task<IActionResult> DeleteReview(Guid Id)
        {
            var command = new DeleteReviewCommand(Id);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }

    }
}