using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.Reviews.Command;
using BarberBooking.API.CQRS.Reviews.Queries;
using BarberBooking.API.Dto.DtoReview;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.ReviewFilters;
using MediatR;
using Microsoft.AspNetCore.Authorization;
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
        [Authorize]
        [HttpPost("Create-Review")]
        public async Task<IActionResult> CreateReview([FromBody] DtoCreateReview dtoCreateReview)
        {
            var command = new CreateReviewCommand(dtoCreateReview);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [Authorize]
        [HttpDelete("Delete-Review/{Id}")]
        public async Task<IActionResult> DeleteReview(Guid Id)
        {
            var command = new DeleteReviewCommand(Id);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("GetReviewsBySalonId/{salonId}")]
        public async Task<IActionResult> GetReviewsBySalonId(Guid salonId, [FromQuery] PageParams pageParams)
        {
            var command = new GetReviewsBySalonIdQuery(salonId, pageParams);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [Authorize]
        [HttpGet("GetReviewsByClientId")]
        public async Task<IActionResult> GetReviewsByClientId([FromQuery] PageParams pageParams)
        {
            var command = new GetReviewsByClientIdQuery(pageParams);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("GetReviewsByMasterId/{masterId}")]
        public async Task<IActionResult> GetReviewsByMasterId(Guid masterId, [FromQuery] PageParams pageParams)
        {
            var command = new GetReviewsByMasterIdQuery(masterId, pageParams);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("GetReviewsBySalonIdSort/{salonId}")]
        public async Task<IActionResult> GetReviewsBySalonIdSort(Guid salonId, [FromQuery] PageParams pageParams, [FromQuery] ReviewSort sort)
        {
            var command = new GetReviewsSortBySalonIdQuery(salonId, pageParams, sort);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("GetReviewsByMasterIdSort/{masterId}")]
        public async Task<IActionResult> GetReviewsByMasterIdSort(Guid masterId, [FromQuery] PageParams pageParams, [FromQuery] ReviewSort sort)
        {
            var command = new GetReviewsSortByMasterIdQuery(masterId, pageParams, sort);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [Authorize]
        [HttpPatch("UpdateReview/{Id}")]
        public async Task<IActionResult> UpdateReview(Guid Id, [FromBody] DtoUpdateReview dtoUpdateReview)
        {
            var command = new UpdateReviewCommand(Id, dtoUpdateReview);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [Authorize("Admin")]
        [HttpGet("GetLowRatingReviewsPaged")]
        public async Task<IActionResult> GetLowRatingReviewsPaged([FromQuery] Guid? salonId, [FromQuery] PageParams pageParams)
        {
            var query = new GetLowRatingReviewsPagedQuery(salonId, pageParams);
            var result = await _mediator.Send(query);
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [Authorize("Admin")]
        [HttpGet("GetAllReviewsAdmin")]
        public async Task<IActionResult> GetAllReviewsAdmin([FromQuery] FilterReviews filter, [FromQuery] PageParams pageParams)
        {
            var query = new GetAllReviewsAdminQuery(filter ?? new FilterReviews(), pageParams);
            var result = await _mediator.Send(query);
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
    }
}