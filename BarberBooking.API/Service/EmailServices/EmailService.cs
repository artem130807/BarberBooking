using System.Net;
using System.Net.Mail;
using BarberBooking.API.Contracts.EmailContracts;
using MailKit.Net.Smtp;
using MailKit.Security;
using MimeKit;

namespace BarberBooking.API.Service.EmailServices
{
    public class EmailService : IEmailService
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
            var password = _configuration["Email:Password"] ?? "";
            var fromAddress = _configuration["Email:FromAddress"];
            var fromName = _configuration["Email:FromName"] ?? "BarberBooking";

            var message = new MimeMessage();
            message.From.Add(new MailboxAddress(fromName, fromAddress));
            message.To.Add(MailboxAddress.Parse(email));
            message.Subject = "Код подтверждения BarberBooking";
            message.Body = new TextPart("plain")
            {
                Text = $"Ваш код подтверждения: {code}. Действует 15 минут."
            };
            _logger.LogInformation($"Ваш код подтверждения: {code}. Действует 15 минут.");
            using var client = new MailKit.Net.Smtp.SmtpClient();
            await client.ConnectAsync(smtpHost, smtpPort, SecureSocketOptions.SslOnConnect);
            await client.AuthenticateAsync(username, password);
            await client.SendAsync(message);
            await client.DisconnectAsync(true);
        }
    }
}
