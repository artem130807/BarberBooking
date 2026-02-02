using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;
using BarberBooking.API.Dto;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Queries
{
    public record LoginUserQuery(string Phone, string PasswordHash):IRequest<Result<AuthDto>>;
}