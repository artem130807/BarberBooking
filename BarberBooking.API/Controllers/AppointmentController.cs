using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.Appointments.AppointmentsQueries;
using BarberBooking.API.CQRS.AppointmentsCommands;
using BarberBooking.API.CQRS.AppointmentsCommands.Handlers;
using BarberBooking.API.CQRS.AppointmentsQueries;
using BarberBooking.API.Dto.DtoAppointments;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.AppointmentsFilter;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace BarberBooking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AppointmentController : ControllerBase
    {
        private readonly IMediator _mediator;
        public AppointmentController(IMediator mediator)
        {
            _mediator = mediator;
        }
        [HttpPost("create-appointment")]
        public async Task<IActionResult> CreateAppointment([FromBody] DtoCreateAppointment dtoCreateAppointment)
        {
            var command = new CreateAppointmentCommand(dtoCreateAppointment);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpDelete("delete-appointment{Id}")]
        public async Task<IActionResult> DeleteAppointment(Guid Id)
        {
            var command = new DeleteAppointmentCommand(Id);
            var result = await _mediator.Send(command);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpPatch("update-appointment{Id}")]
        public async Task<IActionResult> UpdateAppointment(Guid Id, [FromBody] DtoUpdateAppointment dtoUpdateAppointment)
        {
            var command = new UpdateAppointmentCommand(Id, dtoUpdateAppointment);
            var result = await _mediator.Send(command);
            return Ok(result);
        }
      
        [HttpGet("get-appointmentClientById{Id}")]
        public async Task<IActionResult> GetClientAppointmentById(Guid Id)
        {
            var query = new GetAppointmentClientByIdHandler(Id);
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("get-appointmentMasterById{Id}")]
        public async Task<IActionResult> GetMasterAppointmentById(Guid Id)
        {
            var query = new GetAppointmentMasterByIdQuery(Id);
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("get-appointmentsByClientId")]
        public async Task<IActionResult> GetAppointmentsByClientId()
        {
            var query = new GetAppointmentsByClientIdQuery();
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("get-appointmentsByMasterId")]
        public async Task<IActionResult> GetAppointmentsByMasterId([FromQuery] FilterAppointments filter, PageParams pageParams)
        {
            var query = new GetAppointmentsByMasterIdQuery(filter, pageParams);
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
         [HttpGet("get-appointmentsByClientIdAndDate")]
        public async Task<IActionResult> GetAppointmentsByClientIdAndDate([FromQuery] DateTime date)
        {
            var query = new GetAppointmentsByClientIdAndDateQuery(date);
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("get-appointmentsByMasterIdAndDate")]
        public async Task<IActionResult> GetAppointmentsByMasterIdAndDate([FromQuery] DateTime date, TimeOnly startTime)
        {
            var query = new GetAppointmentsByMasterIdAndDateQuery(date, startTime);
            var result = await _mediator.Send(query);
            if(result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [HttpGet("GetAppointmentsAwaitingReview")]
        public async Task<IActionResult> GetAppointmentsAwaitingReview([FromQuery] PageParams pageParams)
        {
            var query = new GetAwaitingReviewQuery(pageParams);
            var result = await _mediator.Send(query);
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
        [Authorize("Admin")]
        [HttpGet("get-salon-appointments-paged/{salonId}")]
        public async Task<IActionResult> GetSalonAppointmentsPaged(Guid salonId, [FromQuery] FilterAppointments filter,[FromQuery] PageParams pageParams)
        {
            var query = new GetSalonAppointmentsPagedQuery(salonId, filter, pageParams);
            var result = await _mediator.Send(query);
            if (result.IsFailure)
                return BadRequest(result.Error);
            return Ok(result.Value);
        }
    }
}