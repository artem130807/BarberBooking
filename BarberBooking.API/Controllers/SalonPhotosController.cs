using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.SalonPhotos.Commands;
using BarberBooking.API.CQRS.SalonPhotos.Queries;
using BarberBooking.API.Dto.DtoSalonPhotos;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;

namespace BarberBooking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SalonPhotosController:ControllerBase
    {
        private readonly IMediator _mediator;
        public SalonPhotosController(IMediator mediator)
        {
            _mediator = mediator;
        }
        
        [Authorize("Admin")]
        [HttpPost("create-photo")]
        public async Task<IActionResult> CreatePhoto([FromBody] DtoCreateSalonPhoto dtoCreateSalonPhoto)
        {
            var command = new CreateSalonPhotoCommand(dtoCreateSalonPhoto);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
                
        }
        [HttpGet("get-photos/{salonId}")]
        public async Task<IActionResult> GetPhotos(Guid salonId, [FromQuery] PageParams pageParams)
        {
            var command = new GetSalonPhotosQuery(salonId, pageParams);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("get-photo/{Id}")]
        public async Task<IActionResult> GetPhoto(Guid Id)
        {
            var command = new GetSalonPhotoQuery(Id);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [Authorize("Admin")]
        [HttpDelete("delete-photo/{Id}")]
        public async Task<IActionResult> DeletePhoto(Guid Id)
        {
            var command = new DeleteSalonPhotoCommand(Id);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }

    }
}