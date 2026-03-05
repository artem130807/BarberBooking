using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts.ReviewContracts;
using BarberBooking.API.Dto.DtoReview;
using BarberBooking.API.Filters;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Reviews.Queries.Handlers
{
    public class GetReviewsByMasterIdHandler : IRequestHandler<GetReviewsByMasterIdQuery, Result<PagedResult<DtoReviewMasterShortInfo>>>
    {
        private readonly IReviewRepository _reviewRepository;
        private readonly IMapper _mapper;
        public GetReviewsByMasterIdHandler(IReviewRepository reviewRepository, IMapper mapper)
        {
            _reviewRepository = reviewRepository;
            _mapper = mapper;
        }

        public async Task<Result<PagedResult<DtoReviewMasterShortInfo>>> Handle(GetReviewsByMasterIdQuery query, CancellationToken cancellationToken)
        {
            var reviews = await _reviewRepository.GetReviewsByMasterId(query.masterId, query.pageParams);
            if(reviews.Count == 0)
                return Result.Failure<PagedResult<DtoReviewMasterShortInfo>>("Список отзывов пуст");
            var result = _mapper.Map<PagedResult<DtoReviewMasterShortInfo>>(reviews);
            return Result.Success(result);
        }
    }
}