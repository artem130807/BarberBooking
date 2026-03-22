using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts.ReviewContracts;
using BarberBooking.API.Dto.DtoReview;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Reviews.Queries.Handlers
{
    public class GetLowRatingReviewsPagedHandler : IRequestHandler<GetLowRatingReviewsPagedQuery, Result<PagedResult<DtoReviewAdminListItem>>>
    {
        private readonly IReviewRepository _reviewRepository;
        private readonly IMapper _mapper;

        public GetLowRatingReviewsPagedHandler(IReviewRepository reviewRepository, IMapper mapper)
        {
            _reviewRepository = reviewRepository;
            _mapper = mapper;
        }

        public async Task<Result<PagedResult<DtoReviewAdminListItem>>> Handle(GetLowRatingReviewsPagedQuery query, CancellationToken cancellationToken)
        {
            var reviews = await _reviewRepository.GetLowRatingReviewsPaged(query.salonId, query.pageParams);
            if (reviews.Count == 0)
                return Result.Failure<PagedResult<DtoReviewAdminListItem>>("Список отзывов пуст");
            var result = _mapper.Map<PagedResult<DtoReviewAdminListItem>>(reviews);
            return Result.Success(result);
        }
    }
}
