using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoEmail;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Contracts.EmailContracts
{
    public interface IEmailVerficationService
    {
        Task<Result<DtoVerificateResponse>> Verificate(string Code, string Email);
        Task<Result<DtoSendEmailResponse>> SendVerificationAsync(string Email);
        Task DeleteEmailVerificate(string Email);
    }
}