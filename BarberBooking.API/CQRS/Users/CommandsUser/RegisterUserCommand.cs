using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Commands
{
    public record RegisterUserCommand(string Name, string PhoneNumber, string Email ,string PasswordHash, string City):IRequest<Result<AuthDto>>;
}