using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoReview;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Reviews.Queries
{
    public record GetReviewsBySalonIdQuery(Guid salonId, PageParams pageParams):IRequest<Result<PagedResult<DtoReviewSalonShortInfo>>>;
}