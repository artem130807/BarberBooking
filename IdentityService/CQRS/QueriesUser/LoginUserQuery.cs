using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;
using IdentityService.DtoModels;
using MediatR;

namespace IdentityService.CQRS.Queries
{
    public record LoginUserQuery(string Email, string PasswordHash):IRequest<AuthDto>;
}