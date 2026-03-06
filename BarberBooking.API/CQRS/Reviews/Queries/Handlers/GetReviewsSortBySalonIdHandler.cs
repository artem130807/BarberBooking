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
    public class GetReviewsSortBySalonIdHandler : IRequestHandler<GetReviewsSortBySalonIdQuery, Result<PagedResult<DtoReviewSalonShortInfo>>>
    {
        private readonly IReviewRepository _reviewRepository;
        private readonly IMapper _mapper;
        public GetReviewsSortBySalonIdHandler(IReviewRepository reviewRepository, IMapper mapper)
        {
            _reviewRepository = reviewRepository;
            _mapper = mapper;
        }
        public async Task<Result<PagedResult<DtoReviewSalonShortInfo>>> Handle(GetReviewsSortBySalonIdQuery query, CancellationToken cancellationToken)
        {
            var reviews = await _reviewRepository.GetReviewsBySalonIdSort(query.salonId, query.pageParams, query.sort);
            if(reviews.Count == 0)
                return Result.Failure<PagedResult<DtoReviewSalonShortInfo>>("Список отзывов пуст");
            var result = _mapper.Map<PagedResult<DtoReviewSalonShortInfo>>(reviews);
            return Result.Success(result);
        }
    }
}