using System;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.CQRS.MasterStatistic.Queries;
using BarberBooking.API.Filters.Master;
using CSharpFunctionalExtensions;
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
        private readonly IUserContext _userContext;
        private readonly IMasterProfileRepository _masterProfileRepository;

        public MasterStatisticsController(
            IMediator mediator,
            IUserContext userContext,
            IMasterProfileRepository masterProfileRepository)
        {
            _mediator = mediator;
            _userContext = userContext;
            _masterProfileRepository = masterProfileRepository;
        }

        private async Task<Result<Guid>> ResolveCurrentMasterIdAsync()
        {
            var master = await _masterProfileRepository.GetMasterProfileByUserId(_userContext.UserId);
            if (master == null)
                return Result.Failure<Guid>("Профиль мастера не найден");
            return Result.Success(master.Id);
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

        [Authorize]
        [HttpGet("GetMyStatisticWeek")]
        public async Task<IActionResult> GetMyStatisticWeek([FromQuery] MasterStatisticsParams statisticsParams)
        {
            var masterIdRes = await ResolveCurrentMasterIdAsync();
            if (masterIdRes.IsFailure)
                return BadRequest(new { error = masterIdRes.Error });
            var query = new GetMasterStatisticsWeekQuery(masterIdRes.Value, statisticsParams);
            var result = await _mediator.Send(query);
            if (result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }

        [Authorize]
        [HttpGet("GetMyStatisticMounth")]
        public async Task<IActionResult> GetMyStatisticMounth(
            [FromQuery] int mounth,
            [FromQuery] DateOnly date)
        {
            var masterIdRes = await ResolveCurrentMasterIdAsync();
            if (masterIdRes.IsFailure)
                return BadRequest(new { error = masterIdRes.Error });
            var query = new GetMasterStatisticsMounthQuery(masterIdRes.Value, mounth, date);
            var result = await _mediator.Send(query);
            if (result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }

        [Authorize]
        [HttpGet("GetMyStatisticYear")]
        public async Task<IActionResult> GetMyStatisticYear([FromQuery] DateOnly date)
        {
            var masterIdRes = await ResolveCurrentMasterIdAsync();
            if (masterIdRes.IsFailure)
                return BadRequest(new { error = masterIdRes.Error });
            var query = new GetMasterStatisticYearQuery(masterIdRes.Value, date);
            var result = await _mediator.Send(query);
            if (result.IsFailure)
                return BadRequest(new { error = result.Error });
            return Ok(result.Value);
        }
        [Authorize]
        [HttpPost("Create_Master_Stastic")]
        public async Task<IActionResult> CreateMasterStatistic()
        {
            return Ok();
        }
    }
}
