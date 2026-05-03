using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;

namespace IdentityService.Contracts.UserContratcts
{
    public interface IDnsEmailValidator
    {
        Task<Result> ValidateEmailAsync(string Email);
    }
}