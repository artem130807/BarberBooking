using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Security.Claims;
using System.Threading.Tasks;
using IdentityService.CQRS.QueriesAuthorization;
using IdentityService.CQRS.QueriesAuthorization.Handelrs;
using IdentityService.DtoModels;
using IdentityService.Events;
using IdentityService.KafkaServices.KafkaProducerLog;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace IdentityService.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthorizationController : ControllerBase
    {
        private readonly IMediator _medaiator;
        private readonly IKafkaProducerLogService<ApprovedEvent> _approvedProducer;
        private readonly IKafkaProducerLogService<RejectedEvent> _rejectedProducer;
        public AuthorizationController(IMediator medaiator, IKafkaProducerLogService<ApprovedEvent> approvedProducer, IKafkaProducerLogService<RejectedEvent> rejectedProducer)
        {
            _medaiator = medaiator;
            _approvedProducer = approvedProducer;
            _rejectedProducer =rejectedProducer;
        }
        [Authorize(AuthenticationSchemes = "ApiKeys")]
        [HttpPost("check")]
        public async Task<IActionResult> ChechkAuthorization([FromBody] AuthorizationRequest request)
        {
            var query = new CheckAuthorizationQuery(request);
            var result = await _medaiator.Send(query);
            return Ok(result);
        }
        [HttpPost("send-test-event")]
        public async Task<IActionResult> SendTestEvent([FromQuery] bool approved = true)
        {
            try
            {
                var resourceId = Guid.NewGuid();
                var userId = Guid.NewGuid();
                
                if (approved)
                {
                    var approvedEvent = new ApprovedEvent(resourceId, userId, default);
                    await _approvedProducer.ProduceAsync(approvedEvent, CancellationToken.None);
                    return Ok($"ApprovedEvent sent: {resourceId}");
                }
                else
                {
                    var rejectedEvent = new RejectedEvent(resourceId, userId);
                    await _rejectedProducer.ProduceAsync(rejectedEvent, CancellationToken.None);
                    return Ok($"RejectedEvent sent: {resourceId}");
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, ex.Message);
            }
        }
       
    }
}