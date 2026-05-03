using IdentityService;
using IdentityService.Authorization;
using IdentityService.Contracts;
using IdentityService.Provider;
using IdentityService.Repositories;
using IdentityService.Service.AuthHandler;
using MediatR;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;

var builder = WebApplication.CreateBuilder(args);
var configuration = builder.Configuration;

builder.Services.Configure<JwtOptions>(configuration.GetSection(nameof(JwtOptions)));
builder.Services.Configure<IdentityService.Authorization.AuthorizationOptions>(configuration.GetSection(nameof(IdentityService.Authorization.AuthorizationOptions)));

builder.Services.AddDb(configuration);
builder.Services.AddApiAuthentication(configuration);

builder.Services.AddControllers();
builder.Services.AddOpenApi();
builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(typeof(Program).Assembly));

builder.Services.AddScoped<IJwtProvider, JwtProvider>();
builder.Services.AddScoped<IAuthCookieService, AuthCookieService>();
builder.Services.AddScoped<IGenerateByteArrayService, GenerateByteArrayService>();
builder.Services.AddScoped<IRefreshTokenService, RefreshTokenService>();
builder.Services.AddScoped<IRefreshTokenRepository, RefreshTokenRepository>();
builder.Services.AddScoped<IUserRepository, UsersRepository>();
builder.Services.AddScoped<IUserRolesRepository, UserRolesRepository>();
builder.Services.AddScoped<IPermissionsRepository, PermissionsRepository>();
builder.Services.AddScoped<IRolePermissionRepository, RolePermissionRepository>();
builder.Services.AddScoped<IOutboxMessageRepository, OutboxMessageRepository>();
builder.Services.AddScoped<IPasswordHasher, PasswordHasher>();
builder.Services.AddScoped<IPasswordValidatorService, PasswordValidatorService>();
builder.Services.AddScoped<IPermissionService, PermissionsService>();
builder.Services.AddSingleton<IAuthorizationHandler, PermissionHandler>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

app.Run();

