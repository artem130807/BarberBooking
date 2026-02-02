using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Models;

namespace BarberBooking.API.Contracts.EmailContracts
{
    public interface IEmailVerificationRepository
    {
        Task<EmailVerification> GetVerificationByCodeAndEmail(string Code, string Email);
        Task Add(EmailVerification emailVerification);
        Task Delete(string Email);
        Task SaveChangesAsync();
    }
}