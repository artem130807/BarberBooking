using CSharpFunctionalExtensions;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using NotifyService.Application.Contracts;
using NotifyService.Application.Dto.DtoEmail;
using NotifyService.Domain.Models;

namespace NotifyService.Infrastructure.Email;

public sealed class EmailVerificationService : IEmailVerficationService
{
    private readonly IEmailVerificationRepository _emailVerificationRepository;
    private readonly IMemoryCache _cache;
    private readonly IEmailService _emailService;
    private readonly ILogger<EmailVerificationService> _logger;

    public EmailVerificationService(
        IEmailVerificationRepository emailVerificationRepository,
        IMemoryCache memoryCache,
        IEmailService emailService,
        ILogger<EmailVerificationService> logger)
    {
        _emailVerificationRepository = emailVerificationRepository;
        _cache = memoryCache;
        _emailService = emailService;
        _logger = logger;
    }

    private static string GenerateCode() => Random.Shared.Next(100000, 999999).ToString();

    public Task DeleteEmailVerificate(string Email) => _emailVerificationRepository.Delete(Email);

    public async Task<Result<DtoSendEmailResponse>> SendVerificationAsync(string Email)
    {
        var existingCode = await _emailVerificationRepository.GetActiveUnusedCodeByEmail(Email);
        if (existingCode != null)
        {
            var timeSinceLastSend = DateTime.UtcNow - existingCode.LastSentAt;
            if (timeSinceLastSend.TotalSeconds < 60)
            {
                var secondsLeft = 60 - (int)timeSinceLastSend.TotalSeconds;
                return Result.Failure<DtoSendEmailResponse>(
                    $"РџРѕРІС‚РѕСЂРЅР°СЏ РѕС‚РїСЂР°РІРєР° С‡РµСЂРµР·: {secondsLeft} СЃРµРєСѓРЅРґ");
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

        try
        {
            await _emailService.SendVerificationService(verif.Email, verif.Code);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "РќРµ СѓРґР°Р»РѕСЃСЊ РѕС‚РїСЂР°РІРёС‚СЊ РїРёСЃСЊРјРѕ РЅР° {Email}", Email);
            return Result.Failure<DtoSendEmailResponse>("РќРµ СѓРґР°Р»РѕСЃСЊ РѕС‚РїСЂР°РІРёС‚СЊ РїРёСЃСЊРјРѕ");
        }

        var cacheKey = $"verification_{verif.Code}";
        _cache.Set(cacheKey, Email, TimeSpan.FromMinutes(30));

        return Result.Success(new DtoSendEmailResponse
        {
            Message = "РљРѕРґ РїРѕРґС‚РІРµСЂР¶РґРµРЅРёСЏ РѕС‚РїСЂР°РІР»РµРЅ РЅР° РїРѕС‡С‚Сѓ, РґРµР№СЃС‚РІРёС‚РµР»РµРЅ 15 РјРёРЅСѓС‚",
            IsSuccess = true
        });
    }

    public async Task<Result<DtoVerificateResponse>> Verificate(string Code, string Email)
    {
        var result = await _emailVerificationRepository.GetVerificationByCodeAndEmail(Code, Email);
        if (result == null || result.ExpiresAt < DateTime.UtcNow)
            return Result.Failure<DtoVerificateResponse>("РќРµРІРµСЂРЅС‹Р№ РєРѕРґ");

        result.IsUsed = true;
        await _emailVerificationRepository.SaveChangesAsync();

        var cacheKey = $"email_verified_{Email}";
        _cache.Set(cacheKey, true, TimeSpan.FromMinutes(30));

        return Result.Success(new DtoVerificateResponse { Message = "РЈСЃРїРµС€РЅРѕ", IsSuccess = true });
    }
}
