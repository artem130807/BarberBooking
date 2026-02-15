using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Commands
{
    public record UpdatePasswordHashCommand(string Email, string PasswordHash) : IRequest<Result<string>>;
}