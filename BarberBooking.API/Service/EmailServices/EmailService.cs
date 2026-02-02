using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.EmailContracts;

namespace BarberBooking.API.Service.EmailServices
{
    public class EmailService:IEmailService
    {
        private readonly IConfiguration _configuration;
        public EmailService(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        public async Task SendVerificationService(string email, string code)
        {
            await SendViaSmtp(email, code);
        }
        private async Task SendViaSmtp(string email, string code)
        {
            var smtpHost = _configuration["Email:SmtpHost"];
            var smtpPort = int.Parse(_configuration["Email:SmtpPort"]);
            var username = _configuration["Email:Username"];
            var password = _configuration["Email:Password"];
            var fromAddress = _configuration["Email:FromAddress"];
            using var client = new SmtpClient(smtpHost, smtpPort)
            {
                EnableSsl = true,
                Credentials = new NetworkCredential(username, password),
                UseDefaultCredentials = false,
                DeliveryMethod = SmtpDeliveryMethod.Network,
                Timeout = 15000

            };
            var message = new MailMessage
            {
                From = new MailAddress(fromAddress),
                Subject = "Код подтверждения BarberBooking",
                Body = $"Ваш код подтверждения: {code}. Действует 15 минут.",
                IsBodyHtml = false
            };
            message.To.Add(email);
            await client.SendMailAsync(message);
        }
    }
}
