using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts.EmailContracts
{
    public interface IEmailVerificationRepository
    {
        Task<List<EmailVerification>> GetVerifications();
        Task<EmailVerification> GetVerificationByCodeAndEmail(string Code, string Email);
        Task<EmailVerification?> GetEmailVerificationByEmail(string Email);
        Task Add(EmailVerification emailVerification);
        Task RemoveRange(List<EmailVerification> emailVerifications);
        Task Delete(string Email);
        Task SaveChangesAsync();
    }
}