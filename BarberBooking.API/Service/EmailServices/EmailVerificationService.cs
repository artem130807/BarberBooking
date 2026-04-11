using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Metadata.Ecma335;
using System.Threading.Tasks;
using BarberBooking.API.Contracts;
using BarberBooking.API.Contracts.EmailContracts;
using BarberBooking.API.Dto.DtoEmail;
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
        private readonly ILogger<EmailVerificationService> _logger;
        public EmailVerificationService(IEmailVerificationRepository emailVerificationRepository, IMemoryCache memoryCache, IEmailService emailService, ILogger<EmailVerificationService> logger)
        {
            _emailVerificationRepository = emailVerificationRepository;
            _cache = memoryCache;
            _emailService = emailService;
            _logger = logger;
        }
        
        private string GenerateCode() => new Random().Next(100000, 999999).ToString();
        public async Task DeleteEmailVerificate(string Email)
        {
            await _emailVerificationRepository.Delete(Email);
        }

        public async Task<Result<DtoSendEmailResponse>> SendVerificationAsync(string Email)
        {
            var existingCode = await _emailVerificationRepository
                .GetActiveUnusedCodeByEmail(Email);
            
            if (existingCode != null)
            {
                var timeSinceLastSend = DateTime.UtcNow - existingCode.LastSentAt;
                if (timeSinceLastSend.TotalSeconds < 60)
                {
                    var secondsLeft = 60 - (int)timeSinceLastSend.TotalSeconds;
                    return Result.Failure<DtoSendEmailResponse>($"Повторная отправка кода через: {secondsLeft} секунд");
                }
            }
            
            var verif = new EmailVerification
            {
                Id = Guid.NewGuid(),
                Email = Email,
                Code = GenerateCode(),
                CratedDate = DateTime.UtcNow,
                LastSentAt = DateTime.UtcNow,
                ExpiresAt = DateTime.UtcNow.AddMinutes(15),
                IsUsed = false
            };
            
            await _emailVerificationRepository.Add(verif);
            await _emailVerificationRepository.SaveChangesAsync();
            
       
            await _emailService.SendVerificationService(verif.Email, verif.Code);
            
            var cacheKey = $"verification_{verif.Code}";
            _cache.Set(cacheKey, Email, TimeSpan.FromMinutes(30));
            
            return Result.Success(new DtoSendEmailResponse
            {
                Message = "Код подтверждения отправлен на почту, действует 15 минут",
                IsSuccess = true
            });
        }

        public async Task<Result<DtoVerificateResponse>> Verificate(string Code, string Email)
        {
            var result = await _emailVerificationRepository.GetVerificationByCodeAndEmail(Code, Email);
             if (result == null || result.ExpiresAt < DateTime.UtcNow)
                return Result.Failure<DtoVerificateResponse>("Неправильный код");
            result.IsUsed = true;
            await _emailVerificationRepository.SaveChangesAsync();
            var cacheKey = $"email_verified_{Email}";
            _cache.Set(cacheKey, true, TimeSpan.FromMinutes(30));
            return Result.Success(new DtoVerificateResponse{Message = "Успешно", IsSuccess = true});
        }
    }
}