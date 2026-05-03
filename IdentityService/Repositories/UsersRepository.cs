using IdentityService.Contracts;
using IdentityService.Enums;
using IdentityService.Models;
using Microsoft.EntityFrameworkCore;

namespace IdentityService.Repositories;

public class UsersRepository : IUserRepository
{
    private readonly IdentityServiceDbContext _context;

    public UsersRepository(IdentityServiceDbContext context)
    {
        _context = context;
    }

    public async Task<Users?> GetUserByPhone(string phone)
    {
        return await _context.Users.FirstOrDefaultAsync(x => x.Phone.Number == phone);
    }

    public async Task<Users> Register(Users users)
    {
        _context.Users.Add(users);
        await _context.SaveChangesAsync();
        return users;
    }

    public async Task<HashSet<PermissionsEnum>> GetUserPermissions(Guid userId)
    {
        var roles = await _context.Users.AsNoTracking().Include(x => x.Roles).ThenInclude(x => x.Permissions)
            .Where(x => x.Id == userId).Select(x => x.Roles).ToListAsync();
        return roles.SelectMany(x => x)
            .SelectMany(x => x.Permissions)
            .Select(x => (PermissionsEnum)x.Id)
            .ToHashSet();
    }

    public async Task UpdatePasswordHash(string email, string password)
    {
        await _context.Users.Where(x => x.Email == email)
            .ExecuteUpdateAsync(x => x.SetProperty(u => u.PasswordHash, password));
        await _context.SaveChangesAsync();
    }

    public async Task<string> UpdateCity(Guid id, string city)
    {
        await _context.Users.Where(x => x.Id == id)
            .ExecuteUpdateAsync(x => x.SetProperty(u => u.City, city));
        await _context.SaveChangesAsync();
        return city;
    }

    public async Task<Users?> GetUserById(Guid id)
    {
        return await _context.Users.FindAsync(id);
    }

    public async Task<Users?> GetUserByEmail(string email)
    {
        return await _context.Users.FirstOrDefaultAsync(x => x.Email == email);
    }

    public async Task<Dictionary<Guid, string>> GetUsersByIds(IEnumerable<Guid> userIds)
    {
        return await _context.Users.Where(u => userIds.Contains(u.Id)).ToDictionaryAsync(u => u.Id, u => u.Name);
    }
}
