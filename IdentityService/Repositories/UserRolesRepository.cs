using IdentityService.Contracts;
using IdentityService.Enums;
using IdentityService.Models;
using Microsoft.EntityFrameworkCore;

namespace IdentityService.Repositories;

public class UserRolesRepository : IUserRolesRepository
{
    private readonly IdentityServiceDbContext _context;

    public UserRolesRepository(IdentityServiceDbContext context)
    {
        _context = context;
    }

    public async Task<List<UserRoles>> GetRolesIdByUserId(Guid userId)
    {
        return await _context.UserRoles.Where(x => x.UserId == userId).ToListAsync();
    }

    public async Task<List<Roles>> GetUserRolesAsync(int roleId)
    {
        return await _context.Roles.Where(x => x.Id == roleId).ToListAsync();
    }

    public async Task AddUserRoleAsync(Guid userId, int roleId)
    {
        await _context.UserRoles.AddAsync(new UserRoles { UserId = userId, RoleId = roleId });
    }

    public async Task RemoveUserRoleAsync(Guid userId, int roleId)
    {
        var userRole = await _context.UserRoles.FirstOrDefaultAsync(x => x.UserId == userId && x.RoleId == roleId);
        if (userRole != null)
            _context.UserRoles.Remove(userRole);
    }

    public async Task<int> GetMaxRole(Guid userId)
    {
        var roleIds = await _context.UserRoles.Where(x => x.UserId == userId).Select(x => x.RoleId).ToListAsync();
        if (roleIds.Count == 0)
            return (int)RolesEnum.User;
        if (roleIds.Contains((int)RolesEnum.Admin))
            return (int)RolesEnum.Admin;
        if (roleIds.Contains((int)RolesEnum.Master))
            return (int)RolesEnum.Master;
        return (int)RolesEnum.User;
    }
}
