using CSharpFunctionalExtensions;
using NotifyService.Application.Dto.DtoEmail;

namespace NotifyService.Application.Contracts;

public interface IEmailVerficationService
{
    Task<Result<DtoVerificateResponse>> Verificate(string Code, string Email);
    Task<Result<DtoSendEmailResponse>> SendVerificationAsync(string Email);
    Task DeleteEmailVerificate(string Email);
}
