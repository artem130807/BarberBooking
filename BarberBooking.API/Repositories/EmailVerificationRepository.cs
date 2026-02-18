using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts.EmailContracts;
using BarberBooking.API.Models;
using Microsoft.EntityFrameworkCore;

namespace BarberBooking.API.Repositories
{
    public class EmailVerificationRepository:IEmailVerificationRepository
    {
        private readonly BarberBookingDbContext _context;
        public EmailVerificationRepository(BarberBookingDbContext context)
        {
            _context = context;
        }

        public async Task Add(EmailVerification emailVerification)
        {
            _context.EmailVerifications.Add(emailVerification);
        }

        public async Task Delete(string Email)
        {
            await _context.EmailVerifications.Where(x => x.Email == Email).ExecuteDeleteAsync();
        }

        public async Task<EmailVerification?> GetActiveUnusedCodeByEmail(string email)
        {
            return await _context.EmailVerifications
            .Where(x => x.Email == email 
                && !x.IsUsed 
                && x.ExpiresAt > DateTime.UtcNow)
            .OrderByDescending(x => x.LastSentAt)
            .FirstOrDefaultAsync();
        }

        public async Task<EmailVerification?> GetEmailVerificationByEmail(string Email)
        {
            return await _context.EmailVerifications.FirstOrDefaultAsync(x => x.Email == Email);
        }

        public async Task<EmailVerification> GetVerificationByCodeAndEmail(string Code, string Email)
        {
            return await _context.EmailVerifications.Where(x => x.Code == Code && x.Email == Email && !x.IsUsed)
            .OrderByDescending(x => x.ExpiresAt).FirstOrDefaultAsync();
        }

        public async Task<List<EmailVerification>> GetVerifications()
        {
            var cutoffTime = DateTime.Now.AddMinutes(-15);
            return await _context.EmailVerifications
            .Where(x => x.LastSentAt <= cutoffTime)
            .ToListAsync();
        }

        public async Task RemoveRange(List<EmailVerification> emailVerifications)
        {
            _context.EmailVerifications.RemoveRange(emailVerifications);
        }

        public async Task SaveChangesAsync()
        {
            await _context.SaveChangesAsync();
        }
    }
}