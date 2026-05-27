using IdentityService.Domain.Models;

namespace IdentityService.Application.Contracts;

public interface IOutboxMessageRepository
{
    Task Add(OutboxMessage message);
    Task Remove(Guid id);
}
