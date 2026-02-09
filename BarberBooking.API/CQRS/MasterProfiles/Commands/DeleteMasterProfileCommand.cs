using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.MasterProfile.Commands
{
    public record DeleteMasterProfileCommand(Guid Id):IRequest<Result<string>>;
}