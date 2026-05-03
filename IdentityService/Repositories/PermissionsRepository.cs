using IdentityService.Contracts;
using IdentityService.Models;
using Microsoft.EntityFrameworkCore;

namespace IdentityService.Repositories;

public class PermissionsRepository : IPermissionsRepository
{
    private readonly IdentityServiceDbContext _context;

    public PermissionsRepository(IdentityServiceDbContext context)
    {
        _context = context;
    }

    public async Task<List<Permissions>> GetPermissionsById(List<int> permissionId)
    {
        if (permissionId == null || !permissionId.Any())
            return new List<Permissions>();

        return await _context.Permissions.Where(x => permissionId.Contains(x.Id)).ToListAsync();
    }
}
