using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API;
using BarberBooking.API.Contracts;
using BarberBooking.API.Domain.ValueObjects;
using BarberBooking.API.Enums;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Repositories
{
    public class UsersRepository : IUserRepository
    {
        private readonly BarberBookingDbContext _context;
        public UsersRepository(BarberBookingDbContext context)
        {
            _context = context;
        }
        public async Task<Users> GetUserByPhone(string phone)
        {
            var user = await _context.Users.FirstOrDefaultAsync(x => x.Phone.Number == phone);
            return user;
        }

        public async Task<Users> Register(Users users)
        {
            _context.Users.Add(users);
            await _context.SaveChangesAsync();
            return users;
        }
        public async Task<HashSet<PermissionsEnum>> GetUserPermissions(Guid userId)
        {
            var roles = await _context.Users.AsNoTracking().Include(x => x.Roles).ThenInclude(x => x.Permissions).Where(x => x.Id == userId).Select(x => x.Roles).ToListAsync();
            return roles.SelectMany(x => x)
            .SelectMany(x => x.Permissions)
            .Select(x => (PermissionsEnum)x.Id)
            .ToHashSet();
        }

        public async Task UpdatePasswordHash(string email, string password)
        {
            await _context.Users.Where(x => x.Email == email)
            .ExecuteUpdateAsync(x => x.SetProperty(x => x.PasswordHash, password));
            await _context.SaveChangesAsync();
        }

        public async Task<string> UpdateCity(Guid Id, string City)
        {
            await _context.Users.Where(x => x.Id == Id)
            .ExecuteUpdateAsync(x => x.SetProperty(x => x.City, City));
            await _context.SaveChangesAsync();
            return City;
        }

        public async Task<Users> GetUserById(Guid Id)
        {
            return await _context.Users.FindAsync(Id);
        }

        public async Task<Users> GetUserByEmail(string email)
        {
            return await _context.Users.FirstOrDefaultAsync(x => x.Email == email);
        }
    }
}