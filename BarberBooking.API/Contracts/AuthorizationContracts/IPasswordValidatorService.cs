using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.Records;

namespace BarberBooking.API.Contracts
{
    public interface IPasswordValidatorService
    {
        Task<PasswordValidationResult> ValidatePasswordAsync(string password);
    }
}