using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoReview;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Reviews.Command
{
    public record CreateReviewCommand(DtoCreateReview dtoCreateReview):IRequest<Result<DtoReviewInfo>>;
   
}