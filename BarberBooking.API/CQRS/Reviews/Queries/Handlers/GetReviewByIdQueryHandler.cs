using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using AutoMapper;
using BarberBooking.API.Contracts.ReviewContracts;
using BarberBooking.API.Dto.DtoReview;
using CSharpFunctionalExtensions;
using MediatR;

namespace BarberBooking.API.CQRS.Reviews.Queries.Handlers
{
    public class GetReviewByIdQueryHandler : IRequestHandler<GetReviewByIdQuery, Result<DtoReviewInfo>>
    {
        private readonly IReviewRepository _reviewRepository;
        private readonly IMapper _mapper;
        public GetReviewByIdQueryHandler(IReviewRepository reviewRepository, IMapper mapper)
        {
            _reviewRepository = reviewRepository;
            _mapper = mapper;
        }
        public async Task<Result<DtoReviewInfo>> Handle(GetReviewByIdQuery query, CancellationToken cancellationToken)
        {
            var review = await _reviewRepository.GetReviewById(query.Id);
            if(review == null)
                return Result.Failure<DtoReviewInfo>("Отзыв не найден");
            var result = _mapper.Map<DtoReviewInfo>(review);
            return Result.Success(result);
        }
    }
}