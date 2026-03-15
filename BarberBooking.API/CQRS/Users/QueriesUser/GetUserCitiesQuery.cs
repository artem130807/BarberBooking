using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Users.QueriesUser
{
    public record GetUserCitiesQuery(string? city):IRequest<Result<List<string>>>;
}