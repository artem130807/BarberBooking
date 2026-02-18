using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;

namespace BarberBooking.API.Contracts.UserContratcts
{
    public interface IDnsEmailValidator
    {
        Task<Result> ValidateEmailAsync(string Email);
    }
}