using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Contracts.EmailContracts
{
    public interface IEmailVerficationService
    {
        Task<bool> Verificate(string Code, string Email);
        Task SendVerificationAsync(string Email);
        Task DeleteEmailVerificate(string Email);
    }
}