using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace BarberBooking.API.Contracts.EmailContracts
{
    public interface IEmailService
    {
        Task SendVerificationService(string email, string code);
    }
}