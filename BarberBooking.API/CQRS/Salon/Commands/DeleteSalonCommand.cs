using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Salons.Commands
{
    public record DeleteSalonCommand(Guid Id):IRequest<Result<string>>;

}