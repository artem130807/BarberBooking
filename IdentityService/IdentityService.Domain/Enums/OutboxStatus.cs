namespace IdentityService.Domain.Enums;

public enum OutboxStatus
{
    Pending = 0,
    Processed = 1,
    Failed = 2,
    Dead = 3
}
