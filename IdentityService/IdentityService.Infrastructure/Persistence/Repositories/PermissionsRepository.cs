using IdentityService.Application.Contracts;
using IdentityService.Domain.Models;
using Microsoft.EntityFrameworkCore;

namespace IdentityService.Infrastructure.Persistence.Repositories;

public class PermissionsRepository : IPermissionsRepository
{
    private readonly IdentityServiceDbContext _context;

    public PermissionsRepository(IdentityServiceDbContext context)
    {
        _context = context;
    }

    public async Task<List<Permissions>> GetPermissionsById(List<int> permissionId)
    {
        if (permissionId == null || permissionId.Count == 0)
            return new List<Permissions>();
        return await _context.Permissions.Where(x => permissionId.Contains(x.Id)).ToListAsync();
    }
}
