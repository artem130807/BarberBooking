using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.EntityFrameworkCore;
using IdentityService;
using IdentityService.Contracts;
using IdentityService.Service;
using IdentityService.Repositories;
using IdentityService.Provider;
using IdentityService.Mapper;
using IdentityService.Authorization;
using Microsoft.AspNetCore.CookiePolicy;
using IdentityService.Enums;
using IdentityService.KafkaServices;
using IdentityService.Models;
using Microsoft.AspNetCore.Authentication;
using IdentityService.Service.AuthHandler;
using IdentityService.Events;
using IdentityService.Consumers;
using IdentityService.KafkaServices.KafkaProducerLog;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddMediatR(cfg => 
    cfg.RegisterServicesFromAssembly(typeof(Program).Assembly));
    
var configuration = builder.Configuration;
builder.Services.AddAuthentication("ApiKeys").AddScheme<AuthenticationSchemeOptions, ApiKeyAuthHandler>("ApiKeys", null);
// Конфигурация JWT 
builder.Services.Configure<JwtOptions>(configuration.GetSection(nameof(JwtOptions)));

// База данных и AutoMapper
builder.Services.AddDb(configuration);
builder.Services.AddHttpClient();
builder.Services.AddHttpClient<ICityValidationService, CityValidationService>();
builder.Services.AddAutoMapper(typeof(MapperProfile));
builder.Services.AddControllers();

//Аутентификация
builder.Services.AddApiAuthentication(configuration);

//Авторизация
builder.Services.Configure<AuthorizationOptions>(configuration.GetSection(nameof(AuthorizationOptions)));
//Swagger
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
///Сервисы аутентификации
builder.Services.AddScoped<IPasswordHasher, PasswordHasher>();
builder.Services.AddScoped<IUserRepository, UsersRepository>();
builder.Services.AddScoped<IJwtProvider, JwtProvider>();
//Сервисы отправки Email Кодов ||Проверки
builder.Services.AddScoped<IEmailVerficationService, EmailVerificationService>();
builder.Services.AddScoped<IEmailService, EmailService>();
builder.Services.AddScoped<IDnsEmailValidator, DnsEmailValidator>();
builder.Services.AddScoped<IPasswordValidatorService, PasswordValidatorService>();
builder.Services.AddScoped<ICityValidationService, CityValidationService>();
builder.Services.AddScoped<IPermissionsRepository, PermissionsRepository>();
builder.Services.AddScoped<IRolePermissionRepository, RolePermissionRepository>();
builder.Services.AddConsumer<string, IdentityMessageHandler<string>>(
    builder.Configuration.GetSection("KafkaConsumer:Restaurant"));

builder.Services.AddConsumer<string, IdentityMessageHandler<string>>(
    builder.Configuration.GetSection("KafkaConsumer:MenuCategory"));

builder.Services.AddProducer<Users>(builder.Configuration.GetSection("Kafka:Users"));
builder.Services.AddProducerLog<ApprovedEvent>(builder.Configuration.GetSection("KafkaProducer:ApprovelEvent"));
builder.Services.AddProducerLog<ApprovedEvent>(builder.Configuration.GetSection("KafkaProducer:RejectedEvent"));
builder.Services.AddScoped(typeof(IKafkaProducerService<>), typeof(KafkaProducerService<>));
builder.Services.AddScoped(typeof(IKafkaProducerLogService<>), typeof(KafkaProducerLogService<>));
builder.Services.AddScoped<IRolesRepository, RolesRepository>();
builder.Services.AddMemoryCache();
builder.Services.AddAuthentication();

var app = builder.Build();
// Configure the HTTP pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}
app.UseHttpsRedirection();
app.UseCookiePolicy(new CookiePolicyOptions
{
     MinimumSameSitePolicy = SameSiteMode.Strict,
     HttpOnly = HttpOnlyPolicy.Always,
     Secure = CookieSecurePolicy.Always
});
    
app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();
app.MapGet("get", () =>
{
    return Results.Ok("nice");
}).RequirePermissions(PermissionsEnum.Delete);

app.Run();