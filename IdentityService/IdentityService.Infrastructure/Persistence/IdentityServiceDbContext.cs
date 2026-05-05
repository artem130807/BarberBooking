using IdentityService.Domain.Models;
using IdentityService.Infrastructure.Authorization;
using IdentityService.Infrastructure.Persistence.Configurations;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace IdentityService.Infrastructure.Persistence;

public class IdentityServiceDbContext(
    DbContextOptions<IdentityServiceDbContext> options,
    IOptions<IdentityService.Infrastructure.Authorization.AuthorizationOptions> authOptions) : DbContext(options)
{
    public DbSet<Users> Users => Set<Users>();
    public DbSet<Roles> Roles => Set<Roles>();
    public DbSet<Permissions> Permissions => Set<Permissions>();
    public DbSet<RolePermissionsEntity> RolePermissions => Set<RolePermissionsEntity>();
    public DbSet<UserRoles> UserRoles => Set<UserRoles>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<OutboxMessage> OutboxMessages => Set<OutboxMessage>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfiguration(new UsersConfigurations());
        modelBuilder.ApplyConfiguration(new RolesConfigurations());
        modelBuilder.ApplyConfiguration(new PermissionsConfigurations());
        modelBuilder.ApplyConfiguration(new RolesPermissionsCofigurations(authOptions.Value));
        modelBuilder.ApplyConfiguration(new RefreshTokenConfigurations());
        modelBuilder.ApplyConfiguration(new OutboxMessageConfigurations());
        base.OnModelCreating(modelBuilder);
    }
}
