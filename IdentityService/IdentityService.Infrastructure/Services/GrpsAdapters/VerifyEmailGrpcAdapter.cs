using IdentityService.Application.Contracts.Interfaces;
using NotifyServiceGrpc;

namespace IdentityService.Infrastructure.Services;

public class VerifyEmailGrpcAdapter : IVerifyEmailGrpcAdapter
{
    private readonly NotificationService.NotificationServiceClient _client;

    public VerifyEmailGrpcAdapter(NotificationService.NotificationServiceClient client)
    {
        _client = client;
    }

    public async Task<bool> IsVerifyEmail(string Email, CancellationToken cancellationToken)
    {
        var response = await _client.IsVerifedEmailAsync(
            new IsVerifedEmailRequest { Email = Email },
            cancellationToken: cancellationToken);

        return response.IsSuccess;
    }
}