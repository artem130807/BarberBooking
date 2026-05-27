using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace NotifyService.Infrastructure.Persistence;

/// <summary>
/// Design-time фабрика для <c>dotnet ef migrations</c> из проекта Infrastructure без запуска хоста.
/// </summary>
public sealed class NotifyDbContextFactory : IDesignTimeDbContextFactory<NotifyDbContext>
{
    public NotifyDbContext CreateDbContext(string[] args)
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
                "Не задан ConnectionStrings:DefaultConnection. Проверьте appsettings в NotifyService.API.");

        var optionsBuilder = new DbContextOptionsBuilder<NotifyDbContext>();
        optionsBuilder.UseNpgsql(connectionString);

        return new NotifyDbContext(optionsBuilder.Options);
    }

    /// <summary>Ищем каталог <c>NotifyService.API</c> с <c>appsettings.json</c>, поднимаясь от текущего каталога.</summary>
    private static string ResolveApiProjectDirectory()
    {
        for (var dir = new DirectoryInfo(Directory.GetCurrentDirectory());
             dir != null;
             dir = dir.Parent)
        {
            var direct = Path.Combine(dir.FullName, "NotifyService.API");
            if (File.Exists(Path.Combine(direct, "appsettings.json")))
                return direct;

            var underService = Path.Combine(dir.FullName, "NotifyService", "NotifyService.API");
            if (File.Exists(Path.Combine(underService, "appsettings.json")))
                return underService;
        }

        throw new InvalidOperationException(
            "Не найден NotifyService.API/appsettings.json. Запускайте dotnet ef из папки NotifyService, " +
            "NotifyService.Infrastructure или из корня решения. " +
            "Либо: dotnet ef migrations add Name --project NotifyService.Infrastructure --startup-project NotifyService.API");
    }
}
