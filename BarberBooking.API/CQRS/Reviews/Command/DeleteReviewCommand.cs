using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Reviews.Command
{
    public record DeleteReviewCommand(Guid Id):IRequest<Result<string>>;
}