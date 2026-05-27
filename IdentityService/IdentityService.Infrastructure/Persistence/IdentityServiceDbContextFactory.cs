using IdentityService.Infrastructure.Authorization;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Options;

namespace IdentityService.Infrastructure.Persistence;
public sealed class IdentityServiceDbContextFactory : IDesignTimeDbContextFactory<IdentityServiceDbContext>
{
    public IdentityServiceDbContext CreateDbContext(string[] args)
    {
        var apiContentRoot = ResolveApiProjectDirectory();
        var configuration = new ConfigurationBuilder()
            .SetBasePath(apiContentRoot)
            .AddJsonFile("appsettings.json", optional: false, reloadOnChange: false)
            .AddJsonFile("appsettings.Development.json", optional: true, reloadOnChange: false)
            .AddEnvironmentVariables()
            .Build();

        var connectionString = configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException(
                "Не задан ConnectionStrings:DefaultConnection. Проверьте appsettings в IdentityService.API.");

        var authOptions = configuration
                .GetSection("AuthorizationOptions")
                .Get<AuthorizationOptions>()
            ?? new AuthorizationOptions();

        var optionsBuilder = new DbContextOptionsBuilder<IdentityServiceDbContext>();
        optionsBuilder.UseNpgsql(connectionString);

        return new IdentityServiceDbContext(optionsBuilder.Options, Options.Create(authOptions));
    }

    private static string ResolveApiProjectDirectory()
    {
        for (var dir = new DirectoryInfo(Directory.GetCurrentDirectory());
             dir != null;
             dir = dir.Parent)
        {
            var direct = Path.Combine(dir.FullName, "IdentityService.API");
            if (File.Exists(Path.Combine(direct, "appsettings.json")))
                return direct;

            var underService = Path.Combine(dir.FullName, "IdentityService", "IdentityService.API");
            if (File.Exists(Path.Combine(underService, "appsettings.json")))
                return underService;
        }

        throw new InvalidOperationException(
            "Не найден IdentityService.API/appsettings.json. Запускайте dotnet ef из папки IdentityService, Infrastructure или корня решения.");
    }
}
