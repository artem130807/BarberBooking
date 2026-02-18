using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto;
using BarberBooking.API.Dto.DtoUsers;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Commands
{
    public record RegisterUserCommand(DtoCreateUser dtoCreateUser):IRequest<Result<AuthDto>>;
}