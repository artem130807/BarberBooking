using NotifyService.Domain.Models;

namespace NotifyService.Application.Contracts;

public interface IEmailVerificationRepository
{
    Task<List<EmailVerification>> GetVerifications();
    Task<EmailVerification?> GetVerificationByCodeAndEmail(string Code, string Email);
    Task<EmailVerification?> GetEmailVerificationByEmail(string Email);
    Task<EmailVerification?> GetActiveUnusedCodeByEmail(string email);
    Task Add(EmailVerification emailVerification);
    Task RemoveRange(List<EmailVerification> emailVerifications);
    Task Delete(string Email);
    Task SaveChangesAsync();
}
