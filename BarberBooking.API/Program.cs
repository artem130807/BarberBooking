using BarberBooking.API;
using BarberBooking.API.Authorization;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.EmailContracts;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.MasterSubscriptionContracts;
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
using BarberBooking.API.Service.EmailServices;
using BarberBooking.API.Service.UpdateService;
using BarberBooking.API.Validator;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.CookiePolicy;

var builder = WebApplication.CreateBuilder(args);
var configuration = builder.Configuration;
builder.WebHost.UseUrls("http://0.0.0.0:5088");
builder.Services.AddAuthentication("ApiKeys").AddScheme<AuthenticationSchemeOptions, ApiKeyAuthHandler>("ApiKeys", null);
// Конфигурация JWT 
builder.Services.Configure<JwtOptions>(configuration.GetSection(nameof(JwtOptions)));
// Add services to the container.

builder.Services.AddDb(configuration);
builder.Services.AddHttpContextAccessor();
builder.Services.AddControllers().ConfigureApiBehaviorOptions(options =>
{
    options.SuppressModelStateInvalidFilter = true; 
});
builder.Services.AddAutoMapper(typeof (MapperProfile));
builder.Services.AddApiAuthentication(configuration);
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();
builder.Services.AddMediatR(cfg => 
{
    cfg.RegisterServicesFromAssembly(typeof(Program).Assembly);
});


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
builder.Services.AddScoped<IRatingService, RatingService>();
builder.Services.AddScoped<IEventStoreRepository, EventStoreRepository>();
builder.Services.AddScoped<IRollBackRatingService, RollBackRatingService>();
builder.Services.AddScoped<IRatingCreateSalonService, RatingCreateSalonService>();
builder.Services.AddScoped<IRatingCreateMasterService, RatingCreateMasterService>();
builder.Services.AddMemoryCache();
var app = builder.Build();

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
app.UseCors(builder => builder
    .AllowAnyOrigin()
    .AllowAnyMethod()
    .AllowAnyHeader());

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.Run();
