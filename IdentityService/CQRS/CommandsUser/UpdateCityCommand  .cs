using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using MediatR;

namespace IdentityService.CQRS.Commands
{
    public record UpdateCityCommand(Guid Id , string City):IRequest<string>;
}