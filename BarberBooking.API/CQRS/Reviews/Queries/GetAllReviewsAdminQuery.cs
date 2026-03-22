using BarberBooking.API.Dto.DtoReview;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.ReviewFilters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Reviews.Queries
{
    public record GetAllReviewsAdminQuery(FilterReviews filter, PageParams pageParams) : IRequest<Result<PagedResult<DtoReviewAdminListItem>>>;
}
