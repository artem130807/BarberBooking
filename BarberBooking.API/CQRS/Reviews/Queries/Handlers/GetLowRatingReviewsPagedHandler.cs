using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts.ReviewContracts;
using BarberBooking.API.Contracts.SalonsAdminContracts;
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
        private readonly AdminSalonAccess _adminSalonAccess;

        public GetLowRatingReviewsPagedHandler(IReviewRepository reviewRepository, IMapper mapper, AdminSalonAccess adminSalonAccess)
        {
            _reviewRepository = reviewRepository;
            _mapper = mapper;
            _adminSalonAccess = adminSalonAccess;
        }

        public async Task<Result<PagedResult<DtoReviewAdminListItem>>> Handle(GetLowRatingReviewsPagedQuery query, CancellationToken cancellationToken)
        {
            var salonIds = await _adminSalonAccess.GetMySalonIdsAsync(cancellationToken);
            if (salonIds.Count == 0)
                return Result.Success(new PagedResult<DtoReviewAdminListItem>(new List<DtoReviewAdminListItem>(), 0));
            if (query.salonId.HasValue && !salonIds.Contains(query.salonId.Value))
                return Result.Failure<PagedResult<DtoReviewAdminListItem>>("Нет доступа к этому салону");
            var reviews = await _reviewRepository.GetLowRatingReviewsPagedForSalonIds(query.salonId, query.pageParams, salonIds);
            var result = _mapper.Map<PagedResult<DtoReviewAdminListItem>>(reviews);
            return Result.Success(result);
        }
    }
}
