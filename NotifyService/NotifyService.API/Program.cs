using FirebaseAdmin;
using Google.Apis.Auth.OAuth2;
using NotifyService.Infrastructure.DependencyInjection;
using NotifyService.Infrastructure.Service.GrpcService;
using NotifyService.Infrastructure.SignalR;

var builder = WebApplication.CreateBuilder(args);
var configuration = builder.Configuration;

builder.Services.AddInfrastructure(configuration);
builder.Services.AddNotifyAuthentication(configuration);
builder.Services.AddGrpc();
builder.Services.AddControllers();
builder.Services.AddSwaggerGen();

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
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapGrpcService<NotifyGrpcService>();
app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.MapHub<NotificationHub>("/notificationHub").RequireAuthorization();

app.Run();
