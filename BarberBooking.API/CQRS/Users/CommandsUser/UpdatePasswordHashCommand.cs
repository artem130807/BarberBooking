using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoUsers;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Commands
{
    public record UpdatePasswordHashCommand(DtoUpdatePassword dtoUpdatePassword) : IRequest<Result<DtoUpdatePasswordResult>>;
}