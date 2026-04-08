using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Messages.Commands
{
    public record DeleteMessageCommand(Guid Id):IRequest<Result<string>>;
}