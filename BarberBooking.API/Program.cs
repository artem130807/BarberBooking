using BarberBooking.API;
using BarberBooking.API.Authorization;
using BarberBooking.API.MapperProfiles;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.EmailContracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.MasterSubscriptionContracts;
using BarberBooking.API.Contracts.MessagesContracts;
using BarberBooking.API.Contracts.ReviewContracts;
using BarberBooking.API.Contracts.SalonsContracts;
using BarberBooking.API.Contracts.UserContratcts;
using BarberBooking.API.Domain.SalonDomain;
using BarberBooking.API.ExtensionsProject;
using BarberBooking.API.Messaging.Producer;
using BarberBooking.API.Provider;
using BarberBooking.API.Repositories;
using BarberBooking.API.Service;
using BarberBooking.API.Service.AuthHandler;
using BarberBooking.API.Service.Background;
using BarberBooking.API.Service.DataService;
using BarberBooking.API.Service.EmailServices;
using BarberBooking.API.Service.UpdateService;
using BarberBooking.API.Validator;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.CookiePolicy;
using BarberBooking.API.Service.MessageService;
using BarberBooking.API.Service.Validator;
using BarberBooking.API.Hubs;
using MediatR;
using Microsoft.AspNetCore.SignalR;
using BarberBooking.API.Contracts.MasterTimeSlotContracts;
using BarberBooking.API.Service.TimeSlotService;
using BarberBooking.API.Contracts.TemplateDayContracts;
using BarberBooking.API.Contracts.WeeklyTemplateContracts;
using BarberBooking.API.Infrastructure.Persistence.Repositories;
using BarberBooking.API.Contracts.MasterServicesContracts;

var builder = WebApplication.CreateBuilder(args);
var configuration = builder.Configuration;
builder.WebHost.UseUrls("http://0.0.0.0:5088");
builder.Services.AddAuthentication("ApiKeys").AddScheme<AuthenticationSchemeOptions, ApiKeyAuthHandler>("ApiKeys", null);
// Конфигурация JWT 
builder.Services.Configure<JwtOptions>(configuration.GetSection(nameof(JwtOptions)));
// Add services to the container.
builder.Services.AddSingleton<IUserIdProvider, SignalRUserIdProvider>();
var signalRBuilder = builder.Services.AddSignalR();
// var redisConnection = configuration["SignalR:Redis"] ?? configuration.GetConnectionString("Redis");
// if (!string.IsNullOrWhiteSpace(redisConnection))
// {
//     signalRBuilder.AddStackExchangeRedis(redisConnection, options =>
//     {
//         options.Configuration.ChannelPrefix = "BarberBooking";
//     });
// }
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
builder.Services.AddScoped<IPasswordValidatorService, PasswordValidatorService>();
builder.Services.Configure<AuthorizationOptions>(configuration.GetSection(nameof(AuthorizationOptions)));
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
builder.Services.AddScoped<IServicesRepository, ServicesRepository>();
builder.Services.AddScoped<IAppointmentsRepository, AppointmentsRepository>();
builder.Services.AddScoped<IMasterTimeSlotRepository, MasterTimeSlotRepository>();
builder.Services.AddScoped<IUpdateServicesService, UpdateServicesService>();
builder.Services.AddScoped<IUpdateAppointmentService, UpdateAppointmentService>();
builder.Services.AddScoped<IUpdateMasterTimeSlotService, UpdateMasterTimeSlotService>();
builder.Services.AddScoped<IUpdateMasterProfile, UpdateMasterProfile>();
builder.Services.AddScoped<IUpdateSalonService, UpdateSalonService>();
///Кафка
builder.Services.Configure<KafkaProducerSalonSettings>(builder.Configuration.GetSection("Kafka"));
builder.Services.AddScoped(typeof(IKafkaProducerSalonEvent<SalonCreatedEvent>), typeof(KafkaProducerSalonEvent<SalonCreatedEvent>));
builder.Services.AddScoped(typeof(IKafkaProducerSalonEvent<SalonDeletedEvent>), typeof(KafkaProducerSalonEvent<SalonDeletedEvent>));
builder.Services.AddScoped(typeof(IKafkaProducerSalonEvent<SalonUpdatedEvent>), typeof(KafkaProducerSalonEvent<SalonUpdatedEvent>));
builder.Services.AddScoped(typeof(IKafkaProducerSalonEvent<SalonAddRatingEvent>), typeof(KafkaProducerSalonEvent<SalonAddRatingEvent>));
builder.Services.AddScoped(typeof(IKafkaProducerSalonEvent<SalonRatingRollbackedEvent>), typeof(KafkaProducerSalonEvent<SalonRatingRollbackedEvent>));
builder.Services.AddKafkaConsumer(configuration);
///
builder.Services.AddScoped<IJwtProvider, JwtProvider>(); 
builder.Services.AddScoped<IPermissionsRepository, PermissionsRepository>();
builder.Services.AddScoped<IRolePermissionRepository, RolePermissionRepository>();
builder.Services.AddScoped<IPasswordHasher, PasswordHasher>();
builder.Services.AddScoped<IUserRepository, UsersRepository>();
builder.Services.AddScoped<IUserRolesRepository, UserRolesRepository>();
builder.Services.AddScoped<IMasterSubscriptionRepository, MasterSubscriptionRepository>();
builder.Services.AddScoped<IReviewRepository, ReviewRepository>();
builder.Services.AddScoped<IEmailVerificationRepository, EmailVerificationRepository>();
builder.Services.AddScoped<IEmailService, EmailService>();
builder.Services.AddScoped<IEmailVerficationService, EmailVerificationService>();
builder.Services.AddScoped<IAuthCookieService, AuthCookieService>();
builder.Services.AddScoped<ISalonsRepository, SalonsRepository>();
builder.Services.AddScoped<IMasterProfileRepository, MasterProfileRepository>();
builder.Services.AddScoped<ICacheService, CacheService>();
builder.Services.AddScoped<IUserContext, UserContext>();
builder.Services.AddScoped<ISalonActiveHandler, SalonActiveHandler>();
builder.Services.AddScoped<IEmailVerficationHandler, EmailVerificateDeleteHandler>();
builder.Services.AddScoped<IDnsEmailValidator, DnsEmailValidator>();
builder.Services.AddScoped<IUserValidatorService, UserValidatorService>();
builder.Services.AddScoped<IAppointmentCreationValidator, AppointmentCreationValidator>();
builder.Services.AddScoped<IRatingService, RatingService>();
builder.Services.AddScoped<IEventStoreRepository, EventStoreRepository>();
builder.Services.AddScoped<IRollBackRatingService, RollBackRatingService>();
builder.Services.AddScoped<IRatingCreateSalonService, RatingCreateSalonService>();
builder.Services.AddScoped<IRatingCreateMasterService, RatingCreateMasterService>();
builder.Services.AddScoped<ICityService, CityService>();
builder.Services.AddScoped<IBadWordService, BadWordService>();
builder.Services.AddScoped<IValidateReviewRepository, ValidateReviewRepository>();
builder.Services.AddScoped<IUpdateReviewService, UpdateReviewService>();
builder.Services.AddScoped<IUpdateRatingService, UpdateRatingService>();
builder.Services.AddScoped<IMessagesRepository, MessagesRepository>();
builder.Services.AddScoped<ISalonStatisticRepository, SalonStatisticRepository>();
builder.Services.AddScoped<ISalonStatiscticHandler, SalonStatiscticHandler>();
builder.Services.AddScoped<ISendMessageService, SendMessageService>();
builder.Services.AddScoped<IMessageAppointmentHandler, MessageAppointmentHandler>();
builder.Services.AddScoped<IMasterStatisticRepository, MasterStatisticRepository>();
builder.Services.AddScoped<IMasterStatisticHandler, MasterStatisticHandler>();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddScoped<ITimeSlotQualifierBookedService, TimeSlotQualifierBookedService>();
builder.Services.AddScoped<IWeeklyTemplateRepository, WeeklyTemplateRepository>();
builder.Services.AddScoped<ITemplateDayRepository, TemplateDayRepository>();
builder.Services.AddScoped<IMasterServicesRepository, MasterServicesRepository>();
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

var app = builder.Build();
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
