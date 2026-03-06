using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts.ReviewContracts;
using BarberBooking.API.Dto.DtoReview;
using BarberBooking.API.Filters;
using BarberBooking.API.Models;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Reviews.Queries.Handlers
{
    public class GetReviewsSortByMasterIdHandler : IRequestHandler<GetReviewsSortByMasterIdQuery, Result<PagedResult<DtoReviewMasterShortInfo>>>
    {
        private readonly IReviewRepository _reviewRepository;
        private readonly IMapper _mapper;
        public GetReviewsSortByMasterIdHandler(IReviewRepository reviewRepository, IMapper mapper)
        {
            _reviewRepository = reviewRepository;
            _mapper = mapper;
        }
        public async Task<Result<PagedResult<DtoReviewMasterShortInfo>>> Handle(GetReviewsSortByMasterIdQuery query, CancellationToken cancellationToken)
        {
            var reviews = await _reviewRepository.GetReviewsByMasterIdSort(query.masterId, query.pageParams, query.sort);
            if(reviews.Count == 0)
                return Result.Failure<PagedResult<DtoReviewMasterShortInfo>>("Список отзывов пуст");
            var result = _mapper.Map<PagedResult<DtoReviewMasterShortInfo>>(reviews);
            return Result.Success(result);
        }
    }
}