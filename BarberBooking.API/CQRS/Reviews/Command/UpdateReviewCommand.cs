using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoReview;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Reviews.Command
{
    public record UpdateReviewCommand(Guid Id, DtoUpdateReview? dtoUpdateReview):IRequest<Result<string>>;
}