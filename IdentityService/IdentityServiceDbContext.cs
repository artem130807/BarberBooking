using IdentityService.Authorization;
using IdentityService.Configurations;
using IdentityService.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace IdentityService;

public class IdentityServiceDbContext(
    DbContextOptions<IdentityServiceDbContext> options,
    IOptions<AuthorizationOptions> authOptions) : DbContext(options)
{
    public DbSet<Users> Users { get; set; }
    public DbSet<Roles> Roles { get; set; }
    public DbSet<Permissions> Permissions { get; set; }
    public DbSet<RolePermissionsEntity> RolePermissions { get; set; }
    public DbSet<UserRoles> UserRoles { get; set; }
    public DbSet<UserFcmToken> UserFcmTokens { get; set; }
    public DbSet<RefreshToken> RefreshTokens { get; set; }
    public DbSet<OutboxMessage> OutboxMessages { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfiguration(new UsersConfigurations());
        modelBuilder.ApplyConfiguration(new RolesConfigurations());
        modelBuilder.ApplyConfiguration(new PermissionsConfigurations());
        modelBuilder.ApplyConfiguration(new RolesPermissionsCofigurations(authOptions.Value));
        modelBuilder.ApplyConfiguration(new RefreshTokenConfigurations());
        modelBuilder.ApplyConfiguration(new UserFcmTokenConfigurations());
        modelBuilder.ApplyConfiguration(new OutboxMessageConfigurations());
        base.OnModelCreating(modelBuilder);
    }
}
