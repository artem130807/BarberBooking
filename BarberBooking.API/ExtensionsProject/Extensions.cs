using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BarberBooking.API.Authorization;
using BarberBooking.API.Domain.ValueObjects;
using BarberBooking.API.Enums;
using BarberBooking.API.Filters;
using BarberBooking.API.Models;
using BarberBooking.API.Provider;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace BarberBooking.API
{
    public static class Extensions
    {
        public static void AddDb(this IServiceCollection services, IConfiguration configuration)
        {
            services.AddDbContext<BarberBookingDbContext>(options =>
            {
                options.UseSqlServer(configuration.GetConnectionString("DefaultConnection"));
            });
        }
         public static void AddApiAuthentication(this IServiceCollection services, IConfiguration configuration)
        {
            var jwtoptions = configuration.GetSection(nameof(JwtOptions)).Get<JwtOptions>();
            services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(JwtBearerDefaults.AuthenticationScheme, options =>
            {
                options.TokenValidationParameters = new()
                {
                    ValidateIssuer = false,
                    ValidateAudience = false,
                    ValidateLifetime = true,
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtoptions.SecretKey))
                };
                options.Events = new JwtBearerEvents
                {
                    OnMessageReceived = context =>
                    {
                        context.Token = context.Request.Cookies["tasty"];
                        
                        if (string.IsNullOrEmpty(context.Token))
                        {
                            var authHeader = context.Request.Headers["Authorization"].FirstOrDefault();
                            if (!string.IsNullOrEmpty(authHeader) && authHeader.StartsWith("Bearer"))
                            {
                                context.Token = authHeader.Substring("Bearer ".Length);
                            }
                        }
                        return Task.CompletedTask;
                    }
                };

            });
             services.AddScoped<IPermissionService, PermissionsService>();
             services.AddSingleton<IAuthorizationHandler, PermissionHandler>();
             services.AddAuthorization();
        }
        public static IEndpointConventionBuilder RequirePermissions<TBuilder>
        (this TBuilder builder, params PermissionsEnum[] permissions) where TBuilder : IEndpointConventionBuilder
        {
            return builder.RequireAuthorization(policy => policy.AddRequirements(new PermissionRequirement(permissions)));
        }
        public static async Task<PagedResult<T>> ToPagedAsync<T>(this IQueryable<T> query, PageParams pageParams)
        {
            var count = await query.CountAsync();
            if (count == 0) return new PagedResult<T>([], 0);
            var page = pageParams.Page ?? 1;
            var PageSize = pageParams.PageSize ?? 10;
            var skip = (page - 1) * PageSize;
            var result = await query.Skip(skip).Take(PageSize).ToListAsync();
            return new PagedResult<T>(result, count); 
        }
    }
}