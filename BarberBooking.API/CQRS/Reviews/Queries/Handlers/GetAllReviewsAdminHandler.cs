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
    public class GetAllReviewsAdminHandler : IRequestHandler<GetAllReviewsAdminQuery, Result<PagedResult<DtoReviewAdminListItem>>>
    {
        private readonly IReviewRepository _reviewRepository;
        private readonly IMapper _mapper;

        public GetAllReviewsAdminHandler(IReviewRepository reviewRepository, IMapper mapper)
        {
            _reviewRepository = reviewRepository;
            _mapper = mapper;
        }

        public async Task<Result<PagedResult<DtoReviewAdminListItem>>> Handle(GetAllReviewsAdminQuery query, CancellationToken cancellationToken)
        {
            var reviews = await _reviewRepository.GetAllReviews(query.filter, query.pageParams);
            var result = _mapper.Map<PagedResult<DtoReviewAdminListItem>>(reviews);
            return Result.Success(result);
        }
    }
}
