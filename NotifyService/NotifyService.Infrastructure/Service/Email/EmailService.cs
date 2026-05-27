using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using MimeKit;
using NotifyService.Application.Contracts;

namespace NotifyService.Infrastructure.Email;

public sealed class EmailService : IEmailService
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<EmailService> _logger;

    public EmailService(IConfiguration configuration, ILogger<EmailService> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    public async Task SendVerificationService(string email, string code)
    {
        var smtpHost = _configuration["Email:SmtpHost"];
        var smtpPort = int.Parse(_configuration["Email:SmtpPort"] ?? "465");
        var username = _configuration["Email:Username"];
        var password = _configuration["Email:Password"] ?? string.Empty;
        var fromAddress = _configuration["Email:FromAddress"];
        var fromName = _configuration["Email:FromName"] ?? "BarberBooking";

        if (string.IsNullOrWhiteSpace(smtpHost) || string.IsNullOrWhiteSpace(fromAddress))
        {
            _logger.LogWarning("Почтовый SMTP не настроен, отправка пропущена.");
            return;
        }

        var message = new MimeMessage();
        message.From.Add(new MailboxAddress(fromName, fromAddress));
        message.To.Add(MailboxAddress.Parse(email));
        message.Subject = "Код подтверждения BarberBooking";
        message.Body = new TextPart("plain")
        {
            Text = $"Код подтверждения: {code}. Действителен 15 минут."
        };

        using var client = new SmtpClient();
        await client.ConnectAsync(smtpHost, smtpPort, SecureSocketOptions.SslOnConnect);
        if (!string.IsNullOrWhiteSpace(username))
            await client.AuthenticateAsync(username, password);
        await client.SendAsync(message);
        await client.DisconnectAsync(true);
    }
}
