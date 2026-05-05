using IdentityService.Application.Contracts;
using IdentityService.Domain.Models;
using Microsoft.EntityFrameworkCore;

namespace IdentityService.Infrastructure.Persistence.Repositories;

public class RolePermissionRepository : IRolePermissionRepository
{
    private readonly IdentityServiceDbContext _context;

    public RolePermissionRepository(IdentityServiceDbContext context)
    {
        _context = context;
    }

    public async Task<List<RolePermissionsEntity>> GetPermissionIdByRoleId(int roleId) =>
        await _context.RolePermissions.Where(x => x.RoleId == roleId).ToListAsync();
}
