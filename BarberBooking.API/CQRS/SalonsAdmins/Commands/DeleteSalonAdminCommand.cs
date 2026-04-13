using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.SalonsAdmins.Commands
{
    public record DeleteSalonAdminCommand(Guid Id):IRequest<Result<string>>;
}