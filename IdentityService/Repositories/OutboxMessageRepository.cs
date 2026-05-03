using IdentityService.Contracts;
using IdentityService.Models;
using Microsoft.EntityFrameworkCore;

namespace IdentityService.Repositories;

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

    public async Task Remove(Guid id)
    {
        await _context.OutboxMessages.Where(x => x.Id == id).ExecuteDeleteAsync();
    }
}
