using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using NotifyService.Application.Contracts;
using NotifyService.Infrastructure.Auth;
using NotifyService.Infrastructure.Email;
using NotifyService.Infrastructure.Identity;
using NotifyService.Infrastructure.Persistence;
using NotifyService.Infrastructure.Persistence.Repositories;
using NotifyService.Infrastructure.Push;
using NotifyService.Infrastructure.SignalR;

namespace NotifyService.Infrastructure.DependencyInjection;

public static class InfrastructureServicesExtensions
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<JwtOptions>(configuration.GetSection(nameof(JwtOptions)));
        services.Configure<FirebasePushOptions>(configuration.GetSection(FirebasePushOptions.SectionName));

        services.AddDbContext<NotifyDbContext>(options =>
            options.UseNpgsql(configuration.GetConnectionString("DefaultConnection")));

        services.AddHttpContextAccessor();
        services.AddMemoryCache();

        services.AddScoped<IUserContext, UserContext>();
        services.AddScoped<IUserFcmTokenRepository, UserFcmTokenRepository>();
        services.AddScoped<IEmailVerificationRepository, EmailVerificationRepository>();
        services.AddScoped<IEmailService, EmailService>();
        services.AddScoped<IEmailVerficationService, EmailVerificationService>();
        services.AddScoped<IFcmPushService, FcmPushService>();
        services.AddScoped<INotificationService, NotificationService>();

        services.AddSingleton<IUserIdProvider, SignalRUserIdProvider>();
        services.AddSignalR();

        return services;
    }

    public static IServiceCollection AddNotifyAuthentication(this IServiceCollection services, IConfiguration configuration)
    {
        var jwtOptions = configuration.GetSection(nameof(JwtOptions)).Get<JwtOptions>()
            ?? throw new InvalidOperationException("JwtOptions missing.");

        var secretKey = jwtOptions.SecretKey
            ?? throw new InvalidOperationException("JwtOptions:SecretKey missing.");

        services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
            })
            .AddJwtBearer(JwtBearerDefaults.AuthenticationScheme, options =>
            {
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = false,
                    ValidateAudience = false,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey)),
                    RoleClaimType = System.Security.Claims.ClaimTypes.Role
                };

                options.Events = new JwtBearerEvents
                {
                    OnMessageReceived = context =>
                    {
                        var accessToken = context.Request.Query["access_token"];
                        var path = context.HttpContext.Request.Path;
                        if (!string.IsNullOrEmpty(accessToken) &&
                            path.StartsWithSegments("/notificationHub"))
                        {
                            context.Token = accessToken;
                            return Task.CompletedTask;
                        }

                        var authHeader = context.Request.Headers.Authorization.FirstOrDefault();
                        if (string.IsNullOrEmpty(authHeader))
                            authHeader = context.Request.Headers["Authorization"].FirstOrDefault();

                        if (!string.IsNullOrEmpty(authHeader) &&
                            authHeader.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
                        {
                            context.Token = authHeader["Bearer ".Length..].Trim();
                            return Task.CompletedTask;
                        }

                        context.Token = context.Request.Cookies["tasty"];
                        return Task.CompletedTask;
                    }
                };
            });

        services.AddAuthorization();
        return services;
    }
}
