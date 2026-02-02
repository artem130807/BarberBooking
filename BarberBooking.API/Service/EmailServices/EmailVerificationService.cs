using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.EmailContracts;
using BarberBooking.API.Models;
using Microsoft.Extensions.Caching.Memory;

namespace BarberBooking.API.Service.EmailServices
{
    public class EmailVerificationService : IEmailVerficationService
    {
        private readonly IEmailVerificationRepository _emailVerificationRepository;
        private readonly IMemoryCache _cache;
        private readonly IEmailService _emailService;
        public EmailVerificationService(IEmailVerificationRepository emailVerificationRepository, IMemoryCache memoryCache, IEmailService emailService)
        {
            _emailVerificationRepository = emailVerificationRepository;
            _cache = memoryCache;
            _emailService = emailService;
        }
        private string GenerateCode() => new Random().Next(100000, 999999).ToString();
        public async Task DeleteEmailVerificate(string Email)
        {
            await _emailVerificationRepository.Delete(Email);
        }

        public async Task SendVerificationAsync(string Email)
        {
            var emailverif = new EmailVerification
            {
                Id = Guid.NewGuid(),
                Email = Email,
                Code = GenerateCode(),
                CratedDate = DateTime.Now,
                ExpiresAt = DateTime.UtcNow.AddMinutes(15),
            };
            await _emailVerificationRepository.Add(emailverif);
            var cacheKey = $"verification_{emailverif.Code}";
            _cache.Set(cacheKey, Email, TimeSpan.FromMinutes(30));
            await _emailService.SendVerificationService(emailverif.Email, emailverif.Code);
            await _emailVerificationRepository.SaveChangesAsync();
        }

        public async Task<bool> Verificate(string Code, string Email)
        {
            var result = await _emailVerificationRepository.GetVerificationByCodeAndEmail(Code, Email);
             if (result == null || result.ExpiresAt < DateTime.UtcNow)
                return false;
            result.IsUsed = true;
            await _emailVerificationRepository.SaveChangesAsync();
            var cacheKey = $"email_verified_{Email}";
            _cache.Set(cacheKey, true, TimeSpan.FromMinutes(30));
            return true;
        }
    }
}