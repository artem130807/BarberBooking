using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Users.QueriesUser
{
    public record GetUserByTokenIdQuery():IRequest<Result<UserInfoDto>>;
}