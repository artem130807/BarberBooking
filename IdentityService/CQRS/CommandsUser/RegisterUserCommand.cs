using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using IdentityService.DtoModels;
using MediatR;

namespace IdentityService.CQRS.Commands
{
    public record RegisterUserCommand(string Name, string Email, string PasswordHash, string City):IRequest<AuthDto>;
}