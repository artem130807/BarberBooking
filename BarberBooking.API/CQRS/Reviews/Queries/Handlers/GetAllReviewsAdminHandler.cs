using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts.MasterProfileContracts;
using BarberBooking.API.Contracts.ReviewContracts;
using BarberBooking.API.Contracts.SalonsAdminContracts;
using BarberBooking.API.Dto.DtoReview;
using BarberBooking.API.Filters;
using BarberBooking.API.Filters.ReviewFilters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Reviews.Queries.Handlers
{
    public class GetAllReviewsAdminHandler : IRequestHandler<GetAllReviewsAdminQuery, Result<PagedResult<DtoReviewAdminListItem>>>
    {
        private readonly IReviewRepository _reviewRepository;
        private readonly IMapper _mapper;
        private readonly AdminSalonAccess _adminSalonAccess;
        private readonly IMasterProfileRepository _masterProfileRepository;

        public GetAllReviewsAdminHandler(IReviewRepository reviewRepository, IMapper mapper, AdminSalonAccess adminSalonAccess, IMasterProfileRepository masterProfileRepository)
        {
            _reviewRepository = reviewRepository;
            _mapper = mapper;
            _adminSalonAccess = adminSalonAccess;
            _masterProfileRepository = masterProfileRepository;
        }

        public async Task<Result<PagedResult<DtoReviewAdminListItem>>> Handle(GetAllReviewsAdminQuery query, CancellationToken cancellationToken)
        {
            var salonIds = await _adminSalonAccess.GetMySalonIdsAsync(cancellationToken);
            if (salonIds.Count == 0)
                return Result.Success(new PagedResult<DtoReviewAdminListItem>(new List<DtoReviewAdminListItem>(), 0));
            var filter = query.filter ?? new FilterReviews();
            if (filter.SalonId.HasValue && !salonIds.Contains(filter.SalonId.Value))
                return Result.Failure<PagedResult<DtoReviewAdminListItem>>("Нет доступа к этому салону");
            if (filter.MasterId.HasValue)
            {
                var master = await _masterProfileRepository.GetMasterProfileById(filter.MasterId.Value);
                if (master == null)
                    return Result.Failure<PagedResult<DtoReviewAdminListItem>>("Мастер не найден");
                if (!salonIds.Contains(master.SalonId))
                    return Result.Failure<PagedResult<DtoReviewAdminListItem>>("Нет доступа к этому мастеру");
            }
            var reviews = await _reviewRepository.GetAllReviewsForSalonIds(filter, query.pageParams, salonIds);
            var result = _mapper.Map<PagedResult<DtoReviewAdminListItem>>(reviews);
            return Result.Success(result);
        }
    }
}
