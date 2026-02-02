using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.CQRS.AppointmentsCommands;
using BarberBooking.API.CQRS.AppointmentsCommands.Handlers;
using BarberBooking.API.CQRS.AppointmentsQueries;
using BarberBooking.API.Dto.DtoAppointments;
using MediatR;
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
            return Ok(result);
        }
        [HttpDelete("delete-appointment{Id}")]
        public async Task<IActionResult> DeleteAppointment(Guid Id)
        {
            var command = new DeleteAppointmentCommand(Id);
            var result = await _mediator.Send(command);
            return Ok(result);
        }
        [HttpPatch("update-appointment{Id}")]
        public async Task<IActionResult> UpdateAppointment(Guid Id, [FromBody] DtoUpdateAppointment dtoUpdateAppointment)
        {
            var command = new UpdateAppointmentCommand(Id, dtoUpdateAppointment);
            var result = await _mediator.Send(command);
            return Ok(result);
        }
        [HttpGet("get-appointmentByIdAndToken{Id}")]
        public async Task<IActionResult> GetAppointmentByIdAndToken(Guid Id, [FromQuery] long token)
        {
            var query = new GetAppointmentByIdAndTokenQuery(Id, token);
            var result = await _mediator.Send(query);
            return Ok(result);
        }
        [HttpGet("get-appointmentByToken")]
        public async Task<IActionResult> GetAppointmentByToken([FromQuery] DateTime dateTime, Guid userId)
        {
            var query = new GetAppointmentByTokenQuery(dateTime , userId);
            var result = await _mediator.Send(query);
            return Ok(result);
        }
        [HttpGet("get-appointments")] 
        public async Task<IActionResult> GetAppointments()
        {
            var query = new GetAppointmentsAsyncQuery();
            var result = await _mediator.Send(query);
            return Ok(result);
        }
        [HttpGet("get-appointmentsByDateTime{masterId}")]
        public async Task<IActionResult> GetByAppointmentDateTime(Guid masterId, [FromQuery] DateTime dateTime)
        {
            var query = new GetByAppointmentDateTimeAsyncQuery(masterId, dateTime);
            var result = await _mediator.Send(query);
            return Ok(result);
        }
        [HttpGet("get-appointmentById{Id}")]
        public async Task<IActionResult> GetAppointmentById(Guid Id)
        {
            var query = new GetByIdAsyncQuery(Id);
            var result = await _mediator.Send(query);
            return Ok(result);
        }
        [HttpGet("get-appointmentByMasterToday{masterId}")]
        public async Task<IActionResult> GetAppointmentByMasterToday(Guid Id)
        {
            var query = new GetByMasterTodayAsyncQuery(Id);
            var result = await _mediator.Send(query);
            return Ok(result);
        }
    }
}