using System.IO;
using BarberBooking.API;
using BarberBooking.API.Contracts;
using BarberBooking.API.DependencyInjection;
using BarberBooking.API.MapperProfiles;
using BarberBooking.API.Provider;
using BarberBooking.API.Service.DataService;
using BarberBooking.API.Hubs;
using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using MediatR;
using Microsoft.AspNetCore.CookiePolicy;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);
var configuration = builder.Configuration;
builder.WebHost.UseUrls("http://0.0.0.0:5088");
builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
    options.KnownNetworks.Clear();
    options.KnownProxies.Clear();
});
builder.Services.Configure<JwtOptions>(configuration.GetSection(nameof(JwtOptions)));
builder.Services.ConfigureApplicationCookie(options =>
{
    options.Cookie.SecurePolicy = CookieSecurePolicy.None;
    options.Cookie.SameSite = SameSiteMode.Lax;
    options.Cookie.Path = "/";
    options.Cookie.HttpOnly = true;
});
builder.Services.AddSingleton<IUserIdProvider, SignalRUserIdProvider>();
var signalRBuilder = builder.Services.AddSignalR();

builder.Services.AddDb(configuration);
builder.Services.AddHttpContextAccessor();
builder.Services.AddControllers().ConfigureApiBehaviorOptions(options =>
{
    options.SuppressModelStateInvalidFilter = true; 
});
builder.Services.AddAutoMapper(typeof(ServicesMappingProfile));
builder.Services.AddApiAuthentication(configuration);
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();
builder.Services.AddMediatR(cfg => 
{
    cfg.RegisterServicesFromAssembly(typeof(Program).Assembly);
});
builder.Services.AddMemoryCache();
builder.Services.AddSingleton<ILoadingCityService, LoadingCityService>();
builder.Services.AddSingleton<ILoadingBadWordService, LoadingBadWordService>();

builder.Services.AddBackgroundServices();
builder.Services.AddApplicationScopedServices(configuration);
var corsOrigins = configuration.GetSection("Cors:AllowedOrigins").Get<string[]>();
if (corsOrigins is { Length: > 0 })
{
    builder.Services.AddCors(options =>
    {
        options.AddPolicy("CorsPolicy", policy =>
        {
            policy.WithOrigins(corsOrigins)
                .AllowAnyHeader()
                .AllowAnyMethod()
                .AllowCredentials();
        });
    });
}

var credentialPath = configuration["Firebase:CredentialPath"];
if (!string.IsNullOrWhiteSpace(credentialPath))
{
    var root = builder.Environment.ContentRootPath;
    var fullPath = Path.IsPathRooted(credentialPath)
        ? credentialPath
        : Path.Combine(root, credentialPath);
    if (File.Exists(fullPath))
    {
        FirebaseApp.Create(new AppOptions { Credential = GoogleCredential.FromFile(fullPath) });
    }
}

var app = builder.Build();

if (Environment.GetEnvironmentVariable("RUN_MIGRATIONS") == "true")
{
    using (var scope = app.Services.CreateScope())
    {
        var dbContext = scope.ServiceProvider.GetRequiredService<BarberBookingDbContext>();
        await dbContext.Database.MigrateAsync();
    }
}


app.UseForwardedHeaders();
app.InitializingCache();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();

    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/openapi/v1.json", "BarberBooking API v1");
        options.RoutePrefix = "swagger"; 
    });
}
app.MapHub<ChatHub>("/chatHub");
app.UseHttpsRedirection();
app.UseCookiePolicy(new CookiePolicyOptions
{
     MinimumSameSitePolicy = SameSiteMode.Strict,
     HttpOnly = HttpOnlyPolicy.Always,
     Secure = CookieSecurePolicy.Always
});
if (corsOrigins is { Length: > 0 })
    app.UseCors("CorsPolicy");
else
{
    app.UseCors(policy => policy
        .AllowAnyOrigin()
        .AllowAnyMethod()
        .AllowAnyHeader());
}

var webRoot = Path.Combine(app.Environment.ContentRootPath, "wwwroot");
Directory.CreateDirectory(Path.Combine(webRoot, "uploads", "images"));
app.UseStaticFiles();

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.MapHub<NotificationHub>("/notificationHub").RequireAuthorization();

app.Run();
