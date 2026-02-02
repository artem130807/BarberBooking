using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.Json;
using System.Threading.Tasks;
using IdentityService.Contracts;
using IdentityService.CQRS.QueriesAuthorization;
using IdentityService.DtoModels;
using IdentityService.Events;
using IdentityService.KafkaServices;
using IdentityService.KafkaServices.KafkaProducerLog;
using MediatR;

namespace IdentityService.Consumers
{
    public class IdentityMessageHandler<TMessage> : IMessageHandler<TMessage> 
    {
        
        private readonly IKafkaProducerLogService<ApprovedEvent> _kafkaApprovedService;
        private readonly IMediator _mediator;
        private readonly ILogger<IdentityMessageHandler<TMessage>> _logger;
        public IdentityMessageHandler(IKafkaProducerLogService<ApprovedEvent> kafkaApprovedService, IMediator mediator, ILogger<IdentityMessageHandler<TMessage>> logger)
        {
            _kafkaApprovedService = kafkaApprovedService;
            _mediator = mediator;
            _logger = logger;
        }
        public async Task HandleAsync(TMessage message, CancellationToken cancellationToken)
        {
            
            if (message is not string json)
                return;
            
            using var doc = JsonDocument.Parse(json);
            var root = doc.RootElement;
            
            if (root.TryGetProperty("EventType", out var eventTypeProp) &&
                root.TryGetProperty("UserId", out var userIdProp) &&
                root.TryGetProperty("ResourceId", out var resourceIdProp))
            {
                
                var eventType = eventTypeProp.GetString();
                var userIdStr = userIdProp.GetString();
                var resourceIdStr = resourceIdProp.GetString();
                
                var resourceType = root.TryGetProperty("Тип ресурса", out var rtProp) 
                    ? rtProp.GetString() 
                    : "Ошибка";
                
                if (string.IsNullOrEmpty(eventType) || 
                    string.IsNullOrEmpty(userIdStr) || 
                    string.IsNullOrEmpty(resourceIdStr))
                {
                    _logger.LogWarning("Поля пустые");
                    return;
                }
                
                if (!Guid.TryParse(userIdStr, out var userId) || 
                    !Guid.TryParse(resourceIdStr, out var resourceId))
                {
                    _logger.LogWarning("Неправильный Guid формат");
                    return;
                }
                
                var request = new AuthorizationRequest
                {
                    UserId = userId,           
                    Action = eventType,        
                    Resource = resourceType    
                };
                
                var query = new CheckAuthorizationQuery(request);
                var result = await _mediator.Send(query, cancellationToken);
                if (result.Allowed)
                {
                    var approvedEvent = new ApprovedEvent(resourceId, userId, true);
                    await _kafkaApprovedService.ProduceAsync(approvedEvent, cancellationToken);
                }
                else
                {
                    var rejectedEvent = new ApprovedEvent(resourceId, userId, false);
                    await _kafkaApprovedService.ProduceAsync(rejectedEvent, cancellationToken);
                }
            }
        }
    }
}