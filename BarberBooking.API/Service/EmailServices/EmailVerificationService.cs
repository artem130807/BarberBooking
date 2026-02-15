using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Metadata.Ecma335;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.EmailContracts;
using BarberBooking.API.Models;
using CSharpFunctionalExtensions;
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

        public async Task<Result<string>> SendVerificationAsync(string Email)
        {
            var verif = await _emailVerificationRepository.GetEmailVerificationByEmail(Email);
            if(verif != null)
            {
                var timeSinceLastSend = DateTime.Now - verif.LastSentAt;
                if(timeSinceLastSend.TotalSeconds < 60)
                {
                    var secondsLeft = 60 - (int)timeSinceLastSend.TotalSeconds;
                    return Result.Failure<string>($"Повторная отправка кода через: {secondsLeft} секунд");
                }
            }
            else
            {
                verif = new EmailVerification
                {
                    Id = Guid.NewGuid(),
                    Email = Email,
                    CratedDate = DateTime.Now,
                };
                await _emailVerificationRepository.Add(verif);
            }
            verif.Code = GenerateCode();
            verif.LastSentAt = DateTime.Now;
            verif.ExpiresAt = DateTime.Now.AddMinutes(15);
           
            await _emailVerificationRepository.SaveChangesAsync();
    
            await _emailService.SendVerificationService(verif.Email, verif.Code);
            

            var cacheKey = $"verification_{verif.Code}";
            _cache.Set(cacheKey, Email, TimeSpan.FromMinutes(30));
            
            return Result.Success("Код подтверждения отправлен на почту, действует 15 минут");
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