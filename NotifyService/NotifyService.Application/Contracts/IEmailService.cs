namespace NotifyService.Application.Contracts;

public interface IEmailService
{
    Task SendVerificationService(string email, string code);
}
