using System.Text;
using IdentityService.Authorization;
using IdentityService.Enums;
using IdentityService.Provider;
using IdentityService.Service.AuthHandler;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace IdentityService;

public static class Extensions
{
    public static void AddDb(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<IdentityServiceDbContext>(options =>
        {
            options.UseNpgsql(configuration.GetConnectionString("DefaultConnection"));
        });
    }

    public static void AddApiAuthentication(this IServiceCollection services, IConfiguration configuration)
    {
        var jwtOptions = configuration.GetSection(nameof(JwtOptions)).Get<JwtOptions>();
        var secretKey = jwtOptions?.SecretKey ?? throw new InvalidOperationException("JwtOptions:SecretKey is missing.");

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
                        var authHeader = context.Request.Headers.Authorization.FirstOrDefault();
                        if (string.IsNullOrEmpty(authHeader))
                            authHeader = context.Request.Headers["Authorization"].FirstOrDefault();
                        if (!string.IsNullOrEmpty(authHeader) && authHeader.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
                        {
                            context.Token = authHeader["Bearer ".Length..].Trim();
                            return Task.CompletedTask;
                        }

                        context.Token = context.Request.Cookies["tasty"];
                        return Task.CompletedTask;
                    }
                };
            })
            .AddScheme<AuthenticationSchemeOptions, ApiKeyAuthHandler>("ApiKeys", null);

        services.AddAuthorization(options =>
        {
            options.AddPolicy("Admin", policy => policy.RequireRole("Admin"));
            options.AddPolicy("AdminOrMaster", policy => policy.RequireRole("Admin", "Master"));
        });
    }

    public static IEndpointConventionBuilder RequirePermissions<TBuilder>(this TBuilder builder, params PermissionsEnum[] permissions)
        where TBuilder : IEndpointConventionBuilder
    {
        return builder.RequireAuthorization(policy => policy.AddRequirements(new PermissionRequirement(permissions)));
    }
}
