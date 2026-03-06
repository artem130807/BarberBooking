using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using BarberBooking.API.Dto.DtoReview;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.ReviewFilters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Reviews.Queries
{
    public record GetReviewsSortBySalonIdQuery(Guid salonId, PageParams pageParams, ReviewSort sort):IRequest<Result<PagedResult<DtoReviewSalonShortInfo>>>;
}