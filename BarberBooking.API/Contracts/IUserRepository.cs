using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Enums;
using BarberBooking.API.Models;


namespace BarberBooking.API.Contracts
{
    public interface IUserRepository
    {
        Task<Users> Register(Users users);
        Task<Users> GetUserByPhone(string phone);
        Task<HashSet<PermissionsEnum>> GetUserPermissions(Guid userId);
        Task UpdatePasswordHash(string phone, string password);
        Task<string> UpdateCity(Guid Id, string City);
        Task<Users> GetUserById(Guid Id);
    }
}