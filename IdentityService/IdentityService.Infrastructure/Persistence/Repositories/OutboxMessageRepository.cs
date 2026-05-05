using IdentityService.Application.Contracts;
using IdentityService.Domain.Models;
using Microsoft.EntityFrameworkCore;

namespace IdentityService.Infrastructure.Persistence.Repositories;

public class OutboxMessageRepository : IOutboxMessageRepository
{
    private readonly IdentityServiceDbContext _context;

    public OutboxMessageRepository(IdentityServiceDbContext context)
    {
        _context = context;
    }

    public async Task Add(OutboxMessage message)
    {
        _context.OutboxMessages.Add(message);
        await Task.CompletedTask;
    }

    public Task Remove(Guid id) =>
        _context.OutboxMessages.Where(x => x.Id == id).ExecuteDeleteAsync();
}
