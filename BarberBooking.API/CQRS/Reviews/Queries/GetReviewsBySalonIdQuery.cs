using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoReview;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Reviews.Queries
{
    public record GetReviewsBySalonIdQuery(Guid salonId):IRequest<Result<List<DtoReviewShortInfo>>>;
}