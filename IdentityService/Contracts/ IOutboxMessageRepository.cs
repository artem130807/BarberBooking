using IdentityService.Models;

namespace IdentityService.Contracts;

public interface IOutboxMessageRepository
{
    Task Add(OutboxMessage message);
    Task Remove(Guid id);
}
