using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace IdentityService.Application.Contracts.Interfaces
{
    public interface IVerifyEmailGrpcAdapter
    {
        Task<bool> IsVerifyEmail(string Email, CancellationToken cancellationToken);
    }
}