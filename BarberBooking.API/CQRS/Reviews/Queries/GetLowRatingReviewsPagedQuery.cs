using System;
using BarberBooking.API.Dto.DtoReview;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Reviews.Queries
{
    public record GetLowRatingReviewsPagedQuery(Guid? salonId, PageParams pageParams) : IRequest<Result<PagedResult<DtoReviewAdminListItem>>>;
}
