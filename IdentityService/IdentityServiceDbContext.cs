using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;
using IdentityService.Models;
using Microsoft.EntityFrameworkCore;

namespace IdentityService
{
    public class IdentityServiceDbContext:DbContext
    {
        public DbSet<Users> Users {get; set;}
        public DbSet<Roles> Roles { get; set; }
        public DbSet<Permissions> Permissions { get; set; }
        public DbSet<RolePermissionsEntity> RolePermissions { get; set; }
        public DbSet<UserRoles> UserRoles { get; set; }
        public DbSet<UserFcmToken> UserFcmTokens { get; set; }
        public DbSet<RefreshToken> RefreshTokens {get; set;}
        public DbSet<OutboxMessage> OutboxMessages {get; set;}
    }
}