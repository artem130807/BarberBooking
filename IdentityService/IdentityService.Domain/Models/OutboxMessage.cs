using CSharpFunctionalExtensions;
using IdentityService.Domain.Enums;

namespace IdentityService.Domain.Models;

public class OutboxMessage
{
    public Guid Id { get; private set; }
    public string AggregateType { get; set; } = null!;
    public string AggregateId { get; set; } = null!;
    public string EventType { get; set; } = null!;
    public string Payload { get; set; } = null!;
    public DateTime OccurredOn { get; private set; }
    public DateTime? ProcessedOn { get; private set; }
    public string? Error { get; private set; }
    public int RetryCount { get; private set; }
    public OutboxStatus Status { get; private set; }

    public static Result<OutboxMessage> Create(string aggregateType, string aggregateId, string eventType, string payload)
    {
        return new OutboxMessage
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
