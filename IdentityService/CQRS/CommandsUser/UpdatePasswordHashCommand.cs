using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityService.DtoModels;
using MediatR;

namespace IdentityService.CQRS.Commands
{
    public record UpdatePasswordHashCommand(string Email, string PasswordHash) : IRequest<Unit>;
}