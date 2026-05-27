using Grpc.Core;
using Microsoft.Extensions.Logging;
using NotifyService.Application.Contracts;
using NotifyService.Infrastructure.Service.GrpcService;
using NotifyServiceGrpc;

namespace NotifyService.Infrastructure.Service.GrpcService;

public class NotifyGrpcService : NotificationService.NotificationServiceBase
{
    private readonly IEmailVerficationService _emailVerficationService;
    private readonly ILogger<NotifyGrpcService> _logger;

    public NotifyGrpcService(IEmailVerficationService emailVerficationService, ILogger<NotifyGrpcService> logger)
    {
        _emailVerficationService = emailVerficationService;
        _logger = logger;
    }

    public override async Task<SendVerificationResponse> SendVerification(SendVerificationRequest request, ServerCallContext context)
    {
        var result = await _emailVerficationService.SendVerificationAsync(request.Email);
        if (result.IsFailure)
        {
            _logger.LogError("Ошибка при отправке кода");
            return new SendVerificationResponse { Message = result.Error, IsSuccess = false };
        }

        return new SendVerificationResponse
        {
            Message = result.Value.Message,
            IsSuccess = result.Value.IsSuccess
        };
    }

    public override async Task<VerificateResponse> Verificate(VerificateRequest request, ServerCallContext context)
    {
        var result = await _emailVerficationService.Verificate(request.Code, request.Email);
        if (result.IsFailure)
        {
            _logger.LogError("Ошибка при проверке кода");
            return new VerificateResponse { Message = result.Error, IsSuccess = false };
        }

        return new VerificateResponse
        {
            Message = result.Value.Message,
            IsSuccess = result.Value.IsSuccess
        };
    }

    public override async Task<IsVerifedEmailResponse> IsVerifedEmail(IsVerifedEmailRequest request, ServerCallContext context)
    {
        var result = await _emailVerficationService.IsVerifiedEmail(request.Email);
        if (result.IsFailure)
        {
            _logger.LogError("Ошибка при проверке email");
            return new IsVerifedEmailResponse { Message = result.Error, IsSuccess = false };
        }

        return new IsVerifedEmailResponse
        {
            Message = result.Value.Message,
            IsSuccess = result.Value.IsSuccess
        };
    }
}