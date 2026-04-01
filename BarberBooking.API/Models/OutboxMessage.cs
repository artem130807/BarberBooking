using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Enums;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Models
{
    public class OutboxMessage
    {
        public Guid Id { get; private set; }               
        public string AggregateType { get; set; } = null!;
        public string AggregateId { get; set; } = null!;        
        public string EventType { get; set; } = null!;
        public string  Payload {get; set;}
        public DateTime OccurredOn { get; private set; }       
        public DateTime? ProcessedOn { get; private set; }
        public string? Error {get; private set;}
        public int RetryCount {get; private set;}
        public OutboxStatus Status {get; private set;}
        public static Result<OutboxMessage> Create(string aggregateType, string aggregateId, string eventType, string payload)
        {
            var message = new OutboxMessage
            {
                Id = Guid.NewGuid(),
                AggregateId = aggregateId,
                AggregateType = aggregateType,
                EventType = eventType,
                Payload = payload,
                OccurredOn = DateTime.UtcNow,
                Status = OutboxStatus.Pending,
                RetryCount = 0
            };
            return message;
        }
        public void MarkProcessed()
        {
            Status = OutboxStatus.Processed;
            ProcessedOn = DateTime.UtcNow;
        }
        public void MarkFailed(string error)
        {
            Status = OutboxStatus.Failed;
            Error = error;
            RetryCount++;
        }
    
        public void MarkDead(string error)
        {
            Status = OutboxStatus.Dead;
            Error = error;
        }
    }
}